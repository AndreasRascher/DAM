query 73000 DMTLogQry
{
    QueryType = Normal;

    elements
    {
        dataitem(DataItemName; DMTLogEntry)
        {
            column(DataFileFolderPath; DataFilePath) { }
            column(DataFileName; DataFileName) { }
            column(QtyRecordID) { Method = Count; }
            column(SourceID; "Source ID") { }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}