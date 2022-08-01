query 110001 "DMTGenBuffTableQry"
{
    QueryType = Normal;

    elements
    {
        dataitem(DataItemName; DMTGenBuffTable)
        {
            column(Import_from_Filename; "Import from Filename") { }
            column(Totals) { Method = Count; }
        }
    }
}