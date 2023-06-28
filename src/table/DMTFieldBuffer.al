table 73005 DMTFieldBuffer
{
    CaptionML = DEU = 'DMT Field Puffer', ENU = 'DMT Field Buffer';
    DataPerCompany = false;
    fields
    {
        field(1; TableNo; Integer) { Caption = 'TableNo', Locked = true; }
        field(2; "No."; Integer) { Caption = 'No.', Locked = true; }
        field(3; TableName; Text[30]) { Caption = 'TableName', Locked = true; }
        field(4; FieldName; Text[30]) { Caption = 'FieldName', Locked = true; }
        field(5; "Type"; Option)
        {
            CaptionML = ENU = 'Type', DEU = 'Type';
            OptionMembers = TableFilter,RecordID,Text,Date,Time,DateFormula,Decimal,Binary,BLOB,Boolean,Integer,Code,Option,BigInteger,Duration,GUID,DateTime;
            OptionCaptionML = ENU = 'TableFilter,RecordID,Text,Date,Time,DateFormula,Decimal,Binary,BLOB,Boolean,Integer,Code,Option,BigInteger,Duration,GUID,DateTime', DEU = 'TableFilter,RecordID,Text,Date,Time,DateFormula,Decimal,Binary,BLOB,Boolean,Integer,Code,Option,BigInteger,Duration,GUID,DateTime';
        }
        field(6; Len; Integer) { Caption = 'Len', Locked = true; }
        field(7; Class; Option)
        {
            CaptionML = ENU = 'Class', DEU = 'Class';
            OptionMembers = Normal,FlowField,FlowFilter;
            OptionCaptionML = ENU = 'Normal,FlowField,FlowFilter', DEU = 'Normal,FlowField,FlowFilter';
        }
        field(8; Enabled; Boolean) { Caption = 'Enabled', Locked = true; }
        field(9; "Type Name"; Text[30]) { Caption = 'Type Name', Locked = true; }
        field(20; "Field Caption"; Text[80]) { Caption = 'Field Caption', Locked = true; }
        field(21; RelationTableNo; Integer) { Caption = 'RelationTableNo', Locked = true; }
        field(22; RelationFieldNo; Integer) { Caption = 'RelationFieldNo', Locked = true; }
        field(23; SQLDataType; Option)
        {
            CaptionML = ENU = 'SQLDataType', DEU = 'SQLDataType';
            OptionMembers = Varchar,Integer,Variant,BigInteger;
            OptionCaptionML = ENU = 'Varchar,Integer,Variant,BigInteger', DEU = 'Varchar,Integer,Variant,BigInteger';
        }
        field(50000; "Table Caption"; Text[80]) { Caption = 'Table Caption', Locked = true; }
        field(50001; "Primary Key"; Text[250]) { Caption = 'Primary Key', Locked = true; }
        field(50002; OptionString; Text[2048]) { Caption = 'OptionString', Locked = true; }
        field(50003; OptionCaption; Text[2048]) { Caption = 'OptionCaption', Locked = true; }
        field(50004; "No. of Records"; Integer) { Caption = 'No. of Records', Locked = true; }
        field(99999; "Data File ID Filter"; Integer)
        {
            Caption = 'Datafile ID Filter', Locked = true;
            FieldClass = FlowFilter;
        }
    }
    keys
    {
        key(Key1; TableNo, "No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Field Caption", FieldName, "No.") { }
    }

    internal procedure ReadFrom(Field: Record Field)
    begin
        Rec.TransferFields(Field);
    end;
}
