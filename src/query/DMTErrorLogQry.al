query 50000 "DMTErrorLogQry"
{
    QueryType = Normal;

    elements
    {
        dataitem(DataItemName; DMTErrorLog)
        {
            column(FromID; "From ID") { }
            column(Import_from_Table_No_; "Import from Table No.") { }
            column(QtyRecordID) { Method = Count; }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}