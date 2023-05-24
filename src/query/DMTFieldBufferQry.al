query 73001 DMTFieldBufferQry
{
    QueryType = Normal;

    elements
    {
        dataitem(DMTFieldBuffer; DMTFieldBuffer)
        {
            column(TableNo; TableNo) { }
            column(Table_Caption; "Table Caption") { }
            column(TableName; TableName) { }
            column(Count) { Method = Count; }
        }
    }
}