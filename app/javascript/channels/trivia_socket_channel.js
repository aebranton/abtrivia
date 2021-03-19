import consumer from "./consumer"

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

      // mapping to be made better later
      console.log("looking for player_count_update");

      var received_action = getAction(data);
      console.log("Action was: " + received_action)

      if (received_action == "player_count_update") {
        $("#current-player-count").html(data['players']);
        $("#min-player-count").html(data['needed']);
        // TODO: Just testing how to call stuff!
        // this.waiting();
      }

      else if (received_action == "starting_timer") {
        if (!$("#pending-min-players").hasClass("ab-hidden")) {
            $("#pending-min-players").addClass("ab-hidden");
        }
        if ($("#session-start-counter").hasClass("ab-hidden")) {
          $("#session-start-counter").removeClass("ab-hidden");          
        }
        $("#countdown-timer").html(data["value"]);
      }

      else if (received_action == "timer_tick") {
        $("#countdown-timer").html(data["value"]);
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

function getAction(data) {
  if ("action" in data) {
    return data['action'];
  }
  return null;
}
