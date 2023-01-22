/*
Idee - Auswahl

Replacement
- Code
- Description
- No. of Conditions
- No. of Replacements

Art		|  Bezeichnung
-------------------------------
Überschrift	| Lagerortmapping
 Von Feld 1 |   Lagerort
 Von Feld 2 |   Lagerplatz
 Nach Feld 1|   Lagerort
 Nach Feld 2|   Lagerplatz
Überschrift	| Produktbuchungsgruppe
 Von Feld 1 |   Buchungsgruppe
 Nach Feld 1|   Produktbuchungsgruppe
-> GetPos - ForeignKey

Idee Zuordnung
- Mehrere Import, das gleiche Mapping
ReplacementFieldSetup
Mapping Code |DataFile ID | Mapping Field Type | Target Field ID




Lagerortmapping
----------------
Kriterien
- Feld 1  --> List of FieldMapping
- Feld 2  --> List of FieldMapping
Zu Ändernde Felder 
- Feld 1  --> List of FieldMapping
- Feld 2  --> List of FieldMapping



DataFile
  FieldMapping
    - m:n ReplacementField
          - DataFileID, ToTableID, ToFieldID
          - Field Type: Condition, Replace
*/

codeunit 110014 "DMTReplacementsMgt"
{
    /// <summary>
    /// Loads all setpup data to temp, best use before record loop
    /// </summary>
    /// <param name="DataFile"></param>
    procedure InitReplacementsInFieldMapping(DataFile: Record DMTDataFile)
    begin
        // Early Exit
        if IsInitialized then
            if not ReplacementFieldSetupForDataFileExists then
                exit;
        ReplacementFieldSetupForDataFileExists := LoadReplacementFieldSetup(TempReplacementFieldSetupGlobal, DataFile);
        if not ReplacementFieldSetupForDataFileExists then
            exit;
        LoadReplacements(TempReplacementGlobal, TempReplacementFieldSetupGlobal);
        LoadReplacementRules(TempReplacementRuleGlobal, TempReplacementGlobal);
        IsInitialized := true;
    end;

    /// <summary>
    /// Loads all setpup data to temp, best use before record loop
    /// </summary>
    /// <param name="DataFile"></param>
    local procedure FindReplacementsInSourceRef(SourceRef: RecordRef) NoOfReplacementsFound: Integer
    var
        SourceFieldValuesPerMappingCode: Dictionary of [Text, Dictionary of [Integer, Text]];
        SourceFieldValues: Dictionary of [Integer, Text];
    begin
        ThrowErrorIfUninitialized();
        SourceFieldValuesPerMappingCode := ReadArgumentFieldValues(SourceRef, TempReplacementGlobal, TempReplacementFieldSetupGlobal);
        if TempReplacementGlobal.FindSet() then
            repeat
                if SourceFieldValuesPerMappingCode.Get(TempReplacementGlobal.Code, SourceFieldValues) then begin
                    TempReplacementRuleGlobal.Reset();
                    TempReplacementRuleGlobal.SetRange("Replacement Code", TempReplacementGlobal.Code);
                    if TempReplacementRuleGlobal.FindSet() then
                        repeat
                            hier weiter machen: Wenn die Regel zutrifft, 
                        den neuen Wert in eine Liste oder Dictionary schreiben
                            IsMatchingRule(SourceFieldValues);
                        until TempReplacementRuleGlobal.Next() = 0;
                end;
            until TempFieldMappingGlobal.Next() = 0;
    end;

    local procedure LoadReplacementFieldSetup(var TempReplacementFieldSetup_Found: Record DMTReplacementFieldSetup temporary; DataFile: Record DMTDataFile) Found: Boolean
    var
        TempReplacementFieldSetup: Record DMTReplacementFieldSetup temporary;
        ReplacementFieldSetup: Record DMTReplacementFieldSetup;
    begin
        ReplacementFieldSetup.SetRange("Data File ID", DataFile.ID);
        if ReplacementFieldSetup.FindSet(false, false) then
            repeat
                TempReplacementFieldSetup := ReplacementFieldSetup;
                TempReplacementFieldSetup.Insert();

            until ReplacementFieldSetup.Next() = 0;
        TempReplacementFieldSetup_Found.Copy(TempReplacementFieldSetup, true);
        exit(TempReplacementFieldSetup_Found.FindFirst());
    end;

    local procedure LoadReplacements(var TempReplacement_Found: Record DMTReplacement temporary; var TempReplacementFieldSetup: Record DMTReplacementFieldSetup temporary) Found: Boolean
    var
        TempReplacement: Record DMTReplacement temporary;
        Replacement: Record DMTReplacement;
    begin
        TempReplacementFieldSetup.Reset();
        if TempReplacementFieldSetup.FindSet() then
            repeat
                if not TempReplacement.Get(TempReplacementFieldSetup."Replacement Code") then begin
                    Replacement.Get(TempReplacementFieldSetup."Replacement Code");
                    TempReplacement := Replacement;
                    TempReplacement.Insert();
                end;
            until TempReplacementFieldSetup.Next() = 0;
        TempReplacement_Found.Copy(TempReplacement, true);
        exit(TempReplacement_Found.FindFirst());
    end;

    local procedure LoadReplacementRules(var TempReplacementRuleFound: Record DMTReplacementRule temporary; var TempReplacement: Record DMTReplacement temporary) OK: Boolean
    var
        TempReplacementRule: Record DMTReplacementRule temporary;
        ReplacementRule: Record DMTReplacementRule;
    begin
        OK := true;
        if not TempReplacement.FindSet() then
            exit(false);
        repeat
            ReplacementRule.SetRange("Replacement Code", TempReplacement.Code);
            if ReplacementRule.FindSet(false, false) then
                repeat
                    TempReplacementRule := ReplacementRule;
                    TempReplacementRule.Insert();
                until ReplacementRule.Next() = 0;
        until TempReplacement.Next() = 0;
        TempReplacementRuleFound.Copy(TempReplacementRule, true);
        OK := TempReplacementRuleFound.FindFirst();
    end;
    /// <summary>
    /// Read all relevant fields required to determine if a replacment rule fits
    /// </summary>
    local procedure ReadArgumentFieldValues(var SourceRef: RecordRef; var TempReplacements: Record DMTReplacement temporary; var TempReplacementFieldSetup: Record DMTReplacementFieldSetup temporary) SourceFieldValuesPerMappingCode: Dictionary of [Text, Dictionary of [Integer, Text]];
    var
        FieldMapping: Record DMTFieldMapping;
        SourceFieldValues: Dictionary of [Integer, Text];
    begin
        TempReplacementFieldSetup.Reset();
        if TempReplacementFieldSetup.FindSet() then
            repeat
                // Store temp            
                if not TempFieldMappingGlobal.Get(TempReplacementFieldSetup."Data File ID", TempReplacementFieldSetup."Target Field No.") then begin
                    FieldMapping.Get(TempReplacementFieldSetup."Data File ID", TempReplacementFieldSetup."Target Field No.");
                    TempFieldMappingGlobal := FieldMapping;
                    TempFieldMappingGlobal.Insert();
                end;
                SourceFieldValues.Add(TempReplacementFieldSetup."Mapping Field Type".AsInteger(), Format(SourceRef.Field(TempFieldMappingGlobal."Source Field No.").Value));
            until TempReplacementFieldSetup.Next() = 0;
    end;

    local procedure ThrowErrorIfUninitialized()
    begin
        if not IsInitialized then
            Error('Not initialized');
    end;

    local procedure IsMatchingRule(var SourceFieldValues: Dictionary of [Integer, Text])
    var
        Conditions: List of [Text];
        IsMatch: Boolean;
        RepFieldType: Enum DMTReplacementFieldType;
    begin
        if SourceFieldValues.ContainsKey(RepFieldType::"Condition 1".AsInteger()) then
            Conditions.Set(1, SourceFieldValues.Get(RepFieldType::"Condition 1".AsInteger()));
        if SourceFieldValues.ContainsKey(RepFieldType::"Condition 2".AsInteger()) then
            Conditions.Set(2, SourceFieldValues.Get(RepFieldType::"Condition 2".AsInteger()));
        if SourceFieldValues.ContainsKey(RepFieldType::"Condition 3".AsInteger()) then
            Conditions.Set(3, SourceFieldValues.Get(RepFieldType::"Condition 3".AsInteger()));
        IsMatch := false;
        case TempReplacementGlobal."No. of Conditions" of
            1:
                begin
                    if Conditions.Get(1) = TempReplacementRuleGlobal."Original Value 1" then
                        IsMatch := true;
                end;
            2:
                begin
                    if Conditions.Get(1) = TempReplacementRuleGlobal."Original Value 1" then
                        if Conditions.Get(2) = TempReplacementRuleGlobal."Original Value 2" then
                            IsMatch := true;
                end;
            else
                Error('Not Supported');
        end;
    end;

    procedure GetReplacementValueFor(SourceFieldRef: FieldRef; var TargedFieldRefWithReplacement: FieldRef) IsReplaced: boolean
    begin
        ThrowErrorIfUninitialized();

    end;



    // procedure FindReplacementValues(var SourceRef: RecordRef) HasReplacementValues: Boolean
    // var
    //     ReplacementRule: Record DMTReplacementRule;
    //     ArgumentFieldValues: List of [Text];
    //     ReplacedFieldValues: Dictionary of [Integer, Text];
    // begin
    //     if not TempReplacementsGlobal.FindSet() then
    //         exit(false);

    //     LoadReplacementFieldSetup(TempReplacementsGlobal, TempFieldMapping);
    //     if not TempReplacementsGlobal.FindSet() then
    //         exit(false);

    //     ReadArgumentFieldValues(SourceRef, ArgumentFieldValues);
    //     repeat
    //         // Find a matching replacmennt rule
    //         if FindMatchingRule(ReplacementRule, TempReplacementsGlobal, ArgumentFieldValues) then begin
    //             // Collect the new values in a FieldID - Value Dictionary
    //             ReplacedFieldValues := GetNewFieldValues(ReplacementRule);
    //         end;
    //     until TempReplacementsGlobal.Next() = 0;
    //     HasReplacementValues := ReplacedFieldValues.Count > 0;
    // end;


    // procedure GetMappingForRef()
    // var
    //     ArgFieldList: List of [Text];
    // begin
    //     ReadArgumentFieldsToText(ArgFieldList);
    //     If IsMatch(ArgFieldRef)
    // end;

    var
        TempReplacementFieldSetupGlobal: Record DMTReplacementFieldSetup temporary;
        TempReplacementGlobal: Record DMTReplacement temporary;
        TempReplacementRuleGlobal: Record DMTReplacementRule temporary;
        TempFieldMappingGlobal: Record DMTFieldMapping temporary;
        MappingValuesArray: array[30] of Variant;
        MappingValues: List of [JsonValue];
        ReplacementFieldSetupForDataFileExists, IsInitialized : Boolean;

}