export function updateHtmlOfAllByClass(cls, content) {
    $(`.${cls}`).each(function() {
        $(this).html(content);
    });
}
    
export function getState(data) {
    if ("current_state" in data) {
        return data['current_state'];
    }
    return null;
}

export function addClassSafe(jqElement, cls) {
    if (!jqElement.hasClass(cls)) {
        jqElement.addClass(cls);
    }
}

export function disableForm() {
    $("#answer-form-fields").attr("disabled", "disabled");
}

export function enableForm() {
    $("#answer-form-fields").removeAttr("disabled");
}

export function setItemActive(item) {
    $(`#${item.id}`).addClass("active");
    disableForm();
}

export function clearActiveItems() {
    for (var i = 1; i < 5; i++) {
        $(`#answer-${i}`).removeClass("active");
    }
    enableForm();
}