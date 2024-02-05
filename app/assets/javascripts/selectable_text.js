function comment(e) {
    // Your comment function here
    console.log("Selected text:", e);
    // For demonstration purposes, log the selected text to the console
    $("#response_text").text(e);
    $("#response_text_form").val(e);
    $("#TTM-Modal").modal('show');
    $(document).off("focusin.modal");
}

function handleSelectionChange() {
    setTimeout(() => {
      var selection = window.getSelection();
      var selectionText = selection.toString();
      if (selectionText.length > 0) {
        var range = selection.getRangeAt(0);
        var rect = range.getBoundingClientRect();

        // Show the comment button above the selected text
        var commentButton = document.getElementById("commentButton");
        commentButton.style.display = "block";
        commentButton.style.top = window.scrollY + rect.top - commentButton.offsetHeight - 5 + "px";
        commentButton.style.left = (rect.left + rect.right - commentButton.offsetWidth) / 2 + "px";

        // Attach click event to the comment button
        commentButton.onclick = function() {
            comment(selectionText);
            // Hide the comment button after clicking
            commentButton.style.display = "none";
        };
    } else {
        // No text selected, hide the comment button
        document.getElementById("commentButton").style.display = "none";
    }}, 100);
};

$("#selectable_content").on("mouseup", handleSelectionChange);