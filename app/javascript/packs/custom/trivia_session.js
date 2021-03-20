class TriviaHelpers {

    static updateHtmlOfAllByClass(cls, content) {
        $(`.${cls}`).each(function() {
            $(this).html(content);
        });
    }
      
    static getState(data) {
        if ("current_state" in data) {
            return data['current_state'];
        }
        return null;
    }
    
    /** 
    * Just to avoid multiple entries of the same class name
    * @param {jQuery Object} jqElement - the jquery object we are working on
    * @param {string} cls - class name to add
    */
     static addClassSafe(jqElement, cls) {
        if (!jqElement.hasClass(cls)) {
            jqElement.addClass(cls);
        }
    }
}




export {TriviaHelpers}