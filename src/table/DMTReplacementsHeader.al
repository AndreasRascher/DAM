table 91010 "DMTReplacementsHeader"
{
    Caption = 'Replacements Header', Comment = 'Ersetzungungen Kopf';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[50])
        {
            Caption = 'Code', comment = 'Code';
            DataClassification = SystemMetadata;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description', Comment = 'Beschreibung';
            DataClassification = SystemMetadata;
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
}