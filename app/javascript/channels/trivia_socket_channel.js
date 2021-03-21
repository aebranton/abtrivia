import consumer from "./consumer"
// import {TriviaHelpers} from "../packs/custom/trivia_session"
//CLIENT SIDE
import {getState, updateHtmlOfAllByClass, disableForm, enableForm, setItemActive, clearActiveItems, addClassSafe} from "../packs/custom/trivia_session"

$(document).on('turbolinks:load', function () {
  
  var trivia_id = $('#ab-session-id').attr('data-trivia-session-id');

  // If we have left the page with an ID to subscribe to, delete the subcription, you left the game!
  if (trivia_id == undefined) {
    consumer.subscriptions['subscriptions'].forEach(element => {
      consumer.subscriptions.remove(element);
    });
  
    // Do not create the subscription if we are not on a page supplying an ID to subscrube to
    return;
  }

  // We are on the trivia session show page, and have a game ready to connect.
  // Subscribe!
  consumer.subscriptions.create({ channel: "TriviaSocketChannel",
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
      // Called when there's incoming data on the websocket for this channel
      var state = getState(data);

      // Always update the player counts
      updateHtmlOfAllByClass("tsd-current-player-count", data['current_players']);
      updateHtmlOfAllByClass("tsd-min-player-count", data['players_to_start']);     
      
      // when we toggle to starting state, swap the layouts to the countdown
      if (state == "starting") {        
        if (!$("#tse-pending-min-players-area").hasClass("ab-hidden")) {
          addClassSafe($("#tse-pending-min-players-area"), "ab-hidden");
          $("#tse-session-start-counter-area").removeClass("ab-hidden");
        }
      }
      
      // WE HAVE A WINNER
      // Catch early if someone is a winner
      if (state == "questioning" && data['current_players'] == 1) {

        // Before we disconnect we gotta end the trivia session
        console.log("SENDING SESSION ENDED");

        this.session_ended();

        // we have a winner 
        // hide review area
        if (!$("#tse-review-area").hasClass("ab-hidden")) {
          addClassSafe($("#tse-review-area"), "ab-hidden");
        }        

        $("#tse-victors-circle").removeClass("ab-hidden");          
        
        consumer.subscriptions['subscriptions'].forEach(element => {
          consumer.subscriptions.remove(element);
        });

        return;
      }

      // Update the timer
      if (data['countdown_value'] > 0) {
        $(".countdown-timer").html(data["countdown_value"]);
      }
      
      // Update the question index
      if (data['question_index'] > 0) {
        $(".tsd-question-index").html(data["question_index"]);
      }

      // question state
      if (state == "questioning") {
        // Change the divs around for questioning
        if (!$("#tse-session-start-counter-area").hasClass("ab-hidden")) {
          addClassSafe($("#tse-session-start-counter-area"), "ab-hidden");
        }  
        if (!$("#tse-review-area").hasClass("ab-hidden")) {
          addClassSafe($("#tse-review-area"), "ab-hidden");
        }
        $("#tse-question-area").removeClass("ab-hidden");

        // Set the question ID on the form
        $("#form-trivia-question-id").prop("value", data["question_id"]);

        $("#question-text").html(data["question_text"]);
        var answer_index = 1
        data["answers"].forEach(answer => {
          var current_button = $(`#answer-${answer_index}`);
          // Set the answer text
          current_button.html(answer["answer"]);
          // Set the answer Id value
          current_button.prop("value", answer["id"]);
          answer_index += 1
        });
      }

      // answer state
      if (state == "answering") {
        clearActiveItems();
        
        // Get the current player
        var player_id = parseInt($('#ab-player-id').attr('data-trivia-player-id'));

        // Display answer area
        if (!$("#tse-question-area").hasClass("ab-hidden")) {
          addClassSafe($("#tse-question-area"), "ab-hidden");
          $("#tse-review-area").removeClass("ab-hidden");
        }

        // display results... i hope
        var answer_index = 1;
        data["answers"].forEach(answer => {
          $(`#result-answer-${answer_index}-text`).html(answer.answer + ": ");
          var count = data["round_results"].filter((obj) => obj.answer_id === answer.id).length;          
          $(`#result-answer-${answer_index}-count`).html(count);
          answer_index += 1;
        });

        // Get my result
        // TODO: NEED TO ADD QUESTION ID TO PLAYER ANSWER FOR CONVENIENCE, THEN FILTER HERE
        var my_answer = data["round_results"].filter((obj) => obj.player_id === player_id && data["question_id"] === obj.question_id);

        // Make sure i have an answer - if i do, check if it is correct.
        // If i failed to answer, eliminate me!
        if (my_answer.length > 0) {
          var target_answer = data["answers"].filter((obj) => obj.id === my_answer[0].answer_id);

          if (target_answer[0].correct) {
            $("#this-players-result").html("Correct!");
          }
          else {
            // ELIMINIATED
            $("#this-players-result").html("Eliminated!");
            $("#eliminated-return-button").removeClass("ab-hidden");
            updateHtmlOfAllByClass("tsd-current-player-count", data['current_players'] - 1);            
            consumer.subscriptions['subscriptions'].forEach(element => {
              console.log(element);
              consumer.subscriptions.remove(element);
            });
          }
        }
        else {
          $("#this-players-result").html("Eliminated!");
          $("#eliminated-return-button").removeClass("ab-hidden");
          updateHtmlOfAllByClass("tsd-current-player-count", data['current_players'] - 1);
          consumer.subscriptions['subscriptions'].forEach(element => {
            console.log(element);
            consumer.subscriptions.remove(element);
          });
        }
      }
    },

    waiting: function() {
      return this.perform('waiting');
    },

    victory: function() {
      return this.perform('victory');
    },

    eliminated: function() {
      return this.perform('eliminated');
    },

    session_ended: function() {
      return this.perform('session_ended');
    },

    incoming: function() {
      return this.perform('incoming');
    },

    ask: function() {
      return this.perform('ask');
    },

    answer: function() {
      return this.perform('answer');
    },

    closed: function() {
      return this.perform('closed');
    }
  })
});

