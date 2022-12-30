query 110000 DMTErrorLogQry
{
    QueryType = Normal;

    elements
    {
        dataitem(DataItemName; DMTErrorLog)
        {
            column(DataFileFolderPath; DataFilePath) { }
            column(DataFileName; DataFileName) { }
            column(QtyRecordID) { Method = Count; }
            column(FromID; "From ID") { }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}