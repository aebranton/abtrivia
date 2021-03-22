import consumer from "./consumer"
import {getState, updateHtmlOfAllByClass, clearActiveItems, addClassSafe} from "../packs/custom/trivia_session"
/** 
* Helper function to remove this users subscription
* @return {undefined} No return
*/
function removeSubscription() {
  consumer.subscriptions['subscriptions'].forEach(element => {
    consumer.subscriptions.remove(element);
  });
}
/** 
* Swap visibility of some dom elements. Give a list of div ID names that need to be made hidden, and a list that need to be made visible. Do not include # id marker.
* @param {Array} makeHidden - array of ID names to hide; ['my-div-id']
* @param {Array} makeVisible - array of ID names to show; ['my-div-id-to-show']
* @return {undefined} no return
*/
function swapVisibleIds(makeHidden, makeVisible) {
  makeHidden.forEach(hide => {
    addClassSafe($(`#${hide}`), "ab-hidden");
  });
  makeVisible.forEach(show => {
    $(`#${show}`).removeClass("ab-hidden");
  });
}

$(document).on('turbolinks:load', function () {
  
  // We stored the trivia session ID on a DOM element so we can retreive it here
  var trivia_id = $('#ab-session-id').attr('data-trivia-session-id');

  // If we have left the page with an ID to subscribe to, delete the subcription, you left the game!
  if (trivia_id == undefined) {
    removeSubscription();
    // Do not create the subscription if we are not on a page supplying an ID to subscribe to
    return;
  }  

  // We are on the trivia session show page, and have a game ready to connect.
  // Subscribe!
  var subscription = consumer.subscriptions.create({ channel: "TriviaSocketChannel",
                                                     trivia_session_id: $('#ab-session-id').attr('data-trivia-session-id'),
                                                     player_id: $('#ab-player-id').attr('data-trivia-player-id') },
  {
    connected() {
      // Called when the subscription is ready for use on the server
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    received(data) {
      // When we receive a broadcast it contains some game data, including a state. Get the state first
      var state = getState(data);
      
      // Get the current player
      var player_id = parseInt($('#ab-player-id').attr('data-trivia-player-id'));
      
      // Quickly check if this players ID is in the eliminated set - if so, do not let them in!
      if (data["eliminated_players"].includes(player_id)) {
        swapVisibleIds(["tse-pending-min-players-area", "tse-session-start-counter-area", "tse-review-area", "tse-question-area"], ["tse-eliminated-block"])
        removeSubscription();
        return;
      }

      // Always update the player counts
      updateHtmlOfAllByClass("tsd-current-player-count", data['current_players']);
      updateHtmlOfAllByClass("tsd-min-player-count", data['players_to_start']);     
      
      // when we toggle to starting state, swap the layouts to the countdown
      if (state == "starting") {   
        swapVisibleIds(["tse-pending-min-players-area"], ["tse-session-start-counter-area"]);
      }
      
      // WE HAVE A WINNER
      // Catch early if someone is a winner
      if (state == "questioning" && data['current_players'] == 1) {

        // Notify the trivia manager to wrap it up!
        this.session_ended();        

        // we have a winner hide review area, and show victory!
        swapVisibleIds(["tse-review-area"], ["tse-victors-circle"]);    
        
        // Return, we are done here
        return;
      }

      // Update the timer counts
      if (data['countdown_value'] > 0) {
        $(".countdown-timer").html(data["countdown_value"]);
      }
      
      // Update the question index
      if (data['question_index'] > 0) {
        $(".tsd-question-index").html(data["question_index"]);
      }

      // STATE IS QUESTIONING
      if (state == "questioning") {
        
        // Make sure we hide other divs that could have been shown, and display the question setup
        swapVisibleIds(["tse-session-start-counter-area", "tse-review-area"], ["tse-question-area"]);        

        // Set the question ID on the form
        $("#form-trivia-question-id").prop("value", data["question_id"]);

        // Set the question text, and answers texts on our form
        $("#question-text").html(data["question_text"]);
        var answer_index = 1
        data["answers"].forEach(answer => {
          var current_button = $(`#answer-${answer_index}`);
          // Set the answer text and ID value
          current_button.html(answer["answer"]);
          current_button.prop("value", answer["id"]);
          answer_index += 1
        });
      }

      // STATE IS ANSWERING
      if (state == "answering") {
        clearActiveItems();        

        // Display answer area
        swapVisibleIds(["tse-question-area"], ["tse-review-area"]);

        // display results... i hope
        var answer_index = 1;
        data["answers"].forEach(answer => {

          // Set what the answer was again so we can see
          if (answer.correct) {
            $(`#result-answer-${answer_index}-text`).html("(Correct) " + answer.answer + ": ");
          }
          else {
            $(`#result-answer-${answer_index}-text`).html(answer.answer + ": ");
          }

          // Display the count of people who picked this answer
          var count = data["round_results"].filter((obj) => obj.answer_id === answer.id).length;          
          $(`#result-answer-${answer_index}-count`).html(count);
          answer_index += 1;
        });

        // Get this players answer 
        var my_answer = data["round_results"].filter((obj) => obj.player_id === player_id && data["question_id"] === obj.question_id);

        // See if this player is continuing or not. Corerct, they move on.
        // Wrong, or didnt answer in time, they are eliminated
        var is_correct = false;
        if (my_answer.length > 0) {

          // Get the answer object for my playeranswer
          var target_answer = data["answers"].filter((obj) => obj.id === my_answer[0].answer_id);

          // Correct
          if (target_answer[0].correct) {
            is_correct = true;
            $("#this-players-result").html("Correct!");
          }
        }

        // If they were wrong or didnt answer
        if (is_correct == false) {

            // Show the eliminated message and provide a go home button      
            $("#this-players-result").html("Eliminated!");
            $("#eliminated-return-button").removeClass("ab-hidden");

            // Remove my player count because i wont get the next timer tick to do so.
            updateHtmlOfAllByClass("tsd-current-player-count", data['current_players'] - 1);    
            
            // Send my eliminated signal so i can get blocked
            this.player_eliminated();

            // Remove me from the socket subscription, I lost.
            removeSubscription();
        }
      }
    },

    // Sent by a user when they are the only one left
    session_ended: function() {
      return this.perform('session_ended');
    },

    // Sent by a user when they are eliminated, to make sure they get added to the blocked list
    player_eliminated: function() {
      return this.perform('player_eliminated');
    },

  });

  this.subscription = subscription;

});

