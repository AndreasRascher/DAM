table 91005 DMTFieldBuffer
{
    CaptionML = DEU = 'DMT Field Puffer', ENU = 'DMT Field Buffer';
    fields
    {
        field(1; "TableNo"; Integer) { CaptionML = ENU = 'TableNo', DEU = 'TableNo'; }
        field(2; "No."; Integer) { CaptionML = ENU = 'No.', DEU = 'No.'; }
        field(3; "TableName"; Text[30]) { CaptionML = ENU = 'TableName', DEU = 'TableName'; }
        field(4; "FieldName"; Text[30]) { CaptionML = ENU = 'FieldName', DEU = 'FieldName'; }
        field(5; "Type"; Option)
        {
            CaptionML = ENU = 'Type', DEU = 'Type';
            OptionMembers = TableFilter,RecordID,Text,Date,Time,DateFormula,Decimal,Binary,BLOB,Boolean,Integer,Code,Option,BigInteger,Duration,GUID,DateTime;
            OptionCaptionML = ENU = 'TableFilter,RecordID,Text,Date,Time,DateFormula,Decimal,Binary,BLOB,Boolean,Integer,Code,Option,BigInteger,Duration,GUID,DateTime', DEU = 'TableFilter,RecordID,Text,Date,Time,DateFormula,Decimal,Binary,BLOB,Boolean,Integer,Code,Option,BigInteger,Duration,GUID,DateTime';
        }
        field(6; "Len"; Integer) { CaptionML = ENU = 'Len', DEU = 'Len'; }
        field(7; "Class"; Option)
        {
            CaptionML = ENU = 'Class', DEU = 'Class';
            OptionMembers = Normal,FlowField,FlowFilter;
            OptionCaptionML = ENU = 'Normal,FlowField,FlowFilter', DEU = 'Normal,FlowField,FlowFilter';
        }
        field(8; "Enabled"; Boolean) { CaptionML = ENU = 'Enabled', DEU = 'Enabled'; }
        field(9; "Type Name"; Text[30]) { CaptionML = ENU = 'Type Name', DEU = 'Type Name'; }
        field(20; "Field Caption"; Text[80]) { CaptionML = ENU = 'Field Caption', DEU = 'Field Caption'; }
        field(21; "RelationTableNo"; Integer) { CaptionML = ENU = 'RelationTableNo', DEU = 'RelationTableNo'; }
        field(22; "RelationFieldNo"; Integer) { CaptionML = ENU = 'RelationFieldNo', DEU = 'RelationFieldNo'; }
        field(23; "SQLDataType"; Option)
        {
            CaptionML = ENU = 'SQLDataType', DEU = 'SQLDataType';
            OptionMembers = Varchar,Integer,Variant,BigInteger;
            OptionCaptionML = ENU = 'Varchar,Integer,Variant,BigInteger', DEU = 'Varchar,Integer,Variant,BigInteger';
        }
        field(50000; "Table Caption"; Text[80]) { CaptionML = ENU = 'Table Caption', DEU = 'Table Caption'; }
        field(50001; "Primary Key"; Text[250]) { CaptionML = ENU = 'Primary Key', DEU = 'Primärschlüssel'; }
        field(50002; "OptionString"; Text[2048]) { Caption = 'OptionString'; }
        field(50003; "OptionCaption"; Text[2048]) { Caption = 'OptionCaption'; }
    }
    keys
    {
        key(Key1; TableNo, "No.")
        {
            Clustered = true;
        }
    }
}
