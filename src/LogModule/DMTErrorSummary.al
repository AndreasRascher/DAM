query 110003 DMTErrorSummary
{
    QueryType = Normal;
    OrderBy = descending(NoOfErrorsByValue);

    elements
    {
        dataitem(DataItemName; DMTLogEntry)
        {
            column(DataFileFolderPath; DataFilePath) { }
            column(DataFileName; DataFileName) { }
            column(Target_Table_No_; "Target Table ID") { }
            column(Target_Field_No_; "Target Field No.") { }
            column(ErrorFieldValue; "Error Field Value") { }
            column(ErrorCode; ErrorCode) { }
            column(NoOfErrorsByValue) { Method = Count; }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}