import consumer from "./consumer"
import {TriviaHelpers} from "../packs/custom/trivia_session"
//CLIENT SIDE

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
      console.log("Client connected to " + $('#ab-session-id').attr('data-trivia-session-id') );
      // Called when the subscription is ready for use on the server
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    received(data) {
      // Called when there's incoming data on the websocket for this channel
      console.log("Received broadcast:");
      console.log(data);

      var state = TriviaHelpers.getState(data);

      // Always update the player counts
      TriviaHelpers.updateHtmlOfAllByClass("tsd-current-player-count", data['current_players']);
      TriviaHelpers.updateHtmlOfAllByClass("tsd-min-player-count", data['players_to_start']);     
      
      // when we toggle to starting state, swap the layouts to the countdown
      if (state == "starting") {        
        if (!$("#tse-pending-min-players-area").hasClass("ab-hidden")) {
          TriviaHelpers.addClassSafe($("#tse-pending-min-players-area"), "ab-hidden");
          $("#tse-session-start-counter-area").removeClass("ab-hidden");
        }
      }

      // Reveal the question area
      if (state == "questioning") {        
        if (!$("#tse-session-start-counter-area").hasClass("ab-hidden")) {
          TriviaHelpers.addClassSafe($("#tse-session-start-counter-area"), "ab-hidden");
          $("#tse-question-area").removeClass("ab-hidden");
        }
      }

      // Update the timer
      if (data['countdown_value'] > 0) {
        $("#countdown-timer").html(data["countdown_value"]);
      }
      
      // Update the question index
      if (data['question_index'] > 0) {
        $("#question-index-tracker").html(data["question_index"]);
      }

      // question state
      if (state == "questioning") {
        $("#question-text").html(data["question_text"]);
        answer_index = 1
        data["answers"].forEach(answer => {
          $(`#answer-${answer_index}`).html(answer["answer"]);
          // Still need to set the id
        });
      }

      // answer state
      if (state == "answering") {
        
      }

    },

    waiting: function() {
      return this.perform('waiting');
    },

    ready: function() {
      return this.perform('ready');
    },

    eliminated: function() {
      return this.perform('eliminated');
    },

    correct: function() {
      return this.perform('correct');
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

