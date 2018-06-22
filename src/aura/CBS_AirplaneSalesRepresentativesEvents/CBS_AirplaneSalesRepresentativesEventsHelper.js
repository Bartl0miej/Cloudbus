({
    renderPage: function(component) {
        let recordsPerPage = component.get("v.repEventsPerPage");
        let records = component.get("v.salesRepsEvents"),
        pageNumber = component.get("v.pageNumber"),
        pageRecords = records.slice((pageNumber - 1) * recordsPerPage, pageNumber * recordsPerPage);
        component.set("v.currentList", pageRecords);
    }
})