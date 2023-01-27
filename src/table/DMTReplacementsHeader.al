table 110006 DMTReplacementsHeaderOLD
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
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
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
        ReplacementsLine: Record DMTReplacementsLineOLD;
    begin
        if ReplacementsLine.filterFor(Rec) then
            ReplacementsLine.DeleteAll(true);
    end;

    internal procedure loadDictionary(var ReplaceValueDictionary: Dictionary of [Text, Text]) NoOfEntries: Integer
    var
        ReplacementsLine: Record DMTReplacementsLineOLD;
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
        DataFile: Record DMTDataFile;
        FieldMapping: Record DMTFieldMapping;
        TableRelationsMetadata: Record "Table Relations Metadata";
        TableNoFilter: Text;
    begin
        TestField("Source Table ID");
        if DataFile.FindSet(false, false) then
            repeat
                TableNoFilter += StrSubstNo('%1|', DataFile."Target Table ID");
            until DataFile.Next() = 0;
        TableNoFilter := TableNoFilter.TrimEnd('|');
        TableRelationsMetadata.SetFilter("Table ID", TableNoFilter);
        TableRelationsMetadata.SetRange("Related Table ID", Rec."Source Table ID");
        TableRelationsMetadata.SetRange("Related Field No.", 1);
        if not TableRelationsMetadata.FindSet() then exit;
        repeat

            FieldMapping.SetRange("Target Table ID", TableRelationsMetadata."Table ID");
            FieldMapping.SetRange("Target Field No.", TableRelationsMetadata."Field No.");
            if FieldMapping.FindSet() then
                repeat
                    if FieldMapping."Replacements Code" = '' then begin
                        FieldMapping.Validate("Replacements Code", Rec.Code);
                        FieldMapping.Modify();
                    end;
                until FieldMapping.Next() = 0;

        until TableRelationsMetadata.Next() = 0;
    end;
}