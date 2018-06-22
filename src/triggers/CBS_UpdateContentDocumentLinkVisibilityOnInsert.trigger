trigger CBS_UpdateContentDocumentLinkVisibilityOnInsert on ContentDocumentLink (before insert) {
    for(ContentDocumentLink link : Trigger.new) {
        link.Visibility = 'AllUsers';
    }
}