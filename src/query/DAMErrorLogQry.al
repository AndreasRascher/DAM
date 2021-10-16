query 91000 DAMErrorLogQry
{
    QueryType = Normal;

    elements
    {
        dataitem(DataItemName; DAMErrorLog)
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