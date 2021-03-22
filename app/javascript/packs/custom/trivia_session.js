/** 
* Changes the content HTML of all items with the given class
* @param {string} cls - the class name to affect. DO not include . prefix.
* @param {string} content - the content htlm to replace into the DOM object
*/
export function updateHtmlOfAllByClass(cls, content) {
    $(`.${cls}`).each(function() {
        $(this).html(content);
    });
}

/** 
* Gets and returns the state key from our data object
* @param {object} data - the data from our trivia session manager
* @return {string | null} returns the string content of the state key, or null if not found.
*/
export function getState(data) {
    if ("current_state" in data) {
        return data['current_state'];
    }
    return null;
}

/** 
* Safely adds a class to the given dom element. Will not double up classes on the element.
* @param {object} jqElement - The dom element as collected by jquery, ie $("#my-id");
* @param {string} cls - the class to add to the dom element
*/
export function addClassSafe(jqElement, cls) {
    if (!jqElement.hasClass(cls)) {
        jqElement.addClass(cls);
    }
}

/** 
* Internal helper for disabling the answer form after you have already answered
*/
export function disableForm() {
    $("#answer-form-fields").attr("disabled", "disabled");
}

/** 
* Internal helper for enabling the answer form for the next question
*/
export function enableForm() {
    $("#answer-form-fields").removeAttr("disabled");
}

/** 
* Internal helper for setting the selected answer to active so the user can see what they picked
*/
export function setItemActive(item) {
    $(`#${item.id}`).addClass("active");
    disableForm();
}

/** 
* Internal helper for clearing the active set on the form
*/
export function clearActiveItems() {
    for (var i = 1; i < 5; i++) {
        $(`#answer-${i}`).removeClass("active");
    }
    enableForm();
}