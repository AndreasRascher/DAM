query 110003 "DMTErrorSummary"
{
    QueryType = Normal;
    OrderBy = descending(NoOfErrorsByValue);

    elements
    {
        dataitem(DataItemName; DMTErrorLog)
        {
            column(DataFileFolderPath; DataFilePath) { }
            column(DataFileName; DataFileName) { }
            column(ImporttoTableNo; "Import to Table No.") { }
            column(ImportToFieldNo; "Import to Field No.") { }
            column(ErrorFieldValue; "Error Field Value") { }
            column(ErrorCode; ErrorCode) { }
            column(NoOfErrorsByValue) { Method = Count; }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}