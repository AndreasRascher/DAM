table 50005 "DMTReplacementsHeader"
{
    Caption = 'Replacements Header', Comment = 'Ersetzungungen Kopf';
    DataClassification = ToBeClassified;
    LookupPageId = DMTReplacementRules;
    DrillDownPageId = DMTReplacementRules;

    fields
    {
        field(1; "Code"; Code[50])
        {
            Caption = 'Code', comment = 'Code';
            DataClassification = SystemMetadata;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description', Comment = 'Beschreibung';
            DataClassification = SystemMetadata;
        }
        field(10; "Source Table ID"; Integer)
        {
            Caption = 'Source Table ID', Comment = 'Herkunftstabellennr.';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
            DataClassification = SystemMetadata;
            trigger OnValidate()
            begin
                CalcFields("Source Table Caption");
            end;
        }
        field(11; "Source Table Caption"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Table Metadata".Caption where(ID = field("Source Table ID")));
            Caption = 'Source Table Caption', Comment = 'Herkunftstabelle';
            Editable = false;
        }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, Description) { }
    }

    trigger OnDelete()
    var
        ReplacementsLine: Record "DMTReplacementsLine";
    begin
        if ReplacementsLine.filterFor(Rec) then
            ReplacementsLine.DeleteAll(true);
    end;

    internal procedure loadDictionary(var ReplaceValueDictionary: Dictionary of [Text, Text]) NoOfEntries: Integer
    var
        ReplacementsLine: Record DMTReplacementsLine;
    begin
        Clear(ReplaceValueDictionary);
        if not ReplacementsLine.filterFor(Rec) then
            exit;
        ReplacementsLine.FindSet(false, false);
        repeat
            if not ReplaceValueDictionary.ContainsKey(ReplacementsLine."Old Value") then
                ReplaceValueDictionary.Add(ReplacementsLine."Old Value", ReplacementsLine."New Value");
        until ReplacementsLine.Next() = 0;
        NoOfEntries := ReplaceValueDictionary.Count;
    end;

    internal procedure proposeAssignments()
    var
        DMTTable: Record DMTTable;
        DMTField: Record DMTField;
        TableRelationsMetadata: Record "Table Relations Metadata";
        TableNoFilter: Text;
    begin
        TestField("Source Table ID");
        if DMTTable.FindSet(false, false) then
            repeat
                TableNoFilter += StrSubstNo('%1|', DMTTable."To Table ID");
            until DMTTable.Next() = 0;
        TableNoFilter := TableNoFilter.TrimEnd('|');
        // TableRelationsMetadata.SetRange("Table ID", DMTField."To Table No.");
        // TableRelationsMetadata.SetRange("Field No.", DMTField."To Field No.");
        // if TableRelationsMetadata.FindFirst() then
        //     if (TableRelationsMetadata.Next() = 0) then begin
        TableRelationsMetadata.setfilter("Table ID", TableNoFilter);
        TableRelationsMetadata.Setrange("Related Table ID", Rec."Source Table ID");
        TableRelationsMetadata.Setrange("Related Field No.", 1);
        if not TableRelationsMetadata.FindSet() then exit;
        repeat
            if DMTField.Get(TableRelationsMetadata."Table ID", TableRelationsMetadata."Field No.") then begin
                if DMTField."Replacements Code" = '' then begin
                    DMTField.Validate("Replacements Code", Rec.Code);
                    DMTField.Modify();
                end;
            end;
        until TableRelationsMetadata.Next() = 0;

    end;
}