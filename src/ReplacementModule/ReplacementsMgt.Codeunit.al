codeunit 110014 "DMTReplacementsMgt"
{
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Table, Database::DMTDataFile, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure DMTDataFile_OnBeforeDeleteEvent(var Rec: Record DMTDataFile; RunTrigger: Boolean)
    var
        Replacement: Record DMTReplacement;
    begin
        if Rec.IsTemporary or not RunTrigger then exit;
        Replacement.SetRange("Data File ID", Rec.ID);
        Replacement.SetRange(LineType, Replacement.LineType::Assignment);
        if not Replacement.IsEmpty then
            Replacement.DeleteAll();
    end;

    procedure InitFor(DataFile: record DMTDataFile; var SourceRef: RecordRef; TargetTableID: Integer)
    var
        CompareFieldNumbers: List of [Integer];
    begin
        HasReplacements := false;
        if not IsInitialized then begin
            IsInitialized := true;
            if not LoadDatafileAssignments(ReplacementAssignmentForDataFileGlobal, DataFile) then
                exit;
            if not LoadReplacementLines(ReplacementLineGlobal, ReplacementAssignmentForDataFileGlobal) then
                exit;
            if not FindArgumentFieldNumbers(CompareFieldNumbers, ReplacementAssignmentForDataFileGlobal) then
                exit;
        end;
        HasReplacements := FindReplacementValues(SourceRef, CompareFieldNumbers, TargetTableID);
    end;

    procedure HasReplacementForTargetField(TargetFieldNo: Integer) Result: Boolean
    begin
        Result := NewValueFieldNumbersGlobal.Contains(TargetFieldNo);
    end;

    internal procedure GetReplacmentValueFor(Number: Integer) ReturnField: FieldRef
    var
        Position: Integer;
    begin
        Position := NewValueFieldNumbersGlobal.IndexOf(Number);
        ReturnField := NewValueFieldArrayGlobal[Position];
    end;

    local procedure FindReplacementValues(var SourceRef: RecordRef; CompareFieldNumbers: List of [Integer]; TargetTableID: Integer) HasReplacementValues: Boolean
    var
        CompareFieldValueArray: array[16] of FieldRef;
    begin
        ReadCompareFields(CompareFieldValueArray, SourceRef, CompareFieldNumbers);
        HasReplacementValues := FindNewValueFields(NewValueFieldArrayGlobal, NewValueFieldNumbersGlobal, CompareFieldValueArray, CompareFieldNumbers, ReplacementLineGlobal, TargetTableID);
    end;

    local procedure LoadDatafileAssignments(var ReplacementAssignmentForDataFile: Record DMTReplacement temporary; DataFile: Record DMTDataFile) Found: Boolean
    var
        ReplacementAssignment: Record DMTReplacement;
        TempReplacementAssignment: Record DMTReplacement temporary;
    begin
        ReplacementAssignment.SetRange(LineType, ReplacementAssignment.LineType::Assignment);
        ReplacementAssignment.SetRange("Data File ID", DataFile.ID);
        if not ReplacementAssignment.FindSet() then
            exit(false);
        repeat
            TempReplacementAssignment := ReplacementAssignment;
            TempReplacementAssignment.Insert();
        until ReplacementAssignment.Next() = 0;
        ReplacementAssignmentForDataFile.Copy(TempReplacementAssignment, true);
        Found := ReplacementAssignmentForDataFile.FindFirst();
    end;

    local procedure LoadReplacementLines(var TempReplacementLineNew: Record DMTReplacement temporary; var ReplacementAssignmentForDataFile: Record DMTReplacement temporary) Found: Boolean
    var
        ReplacementLine: Record DMTReplacement;
        TempReplacementLine: Record DMTReplacement temporary;
    begin
        if not ReplacementAssignmentForDataFile.FindSet() then
            exit(false);
        repeat
            ReplacementLine.SetRange(LineType, ReplacementLine.LineType::Line);
            ReplacementLine.SetRange("Replacement Code", ReplacementAssignmentForDataFile."Replacement Code");
            if ReplacementLine.FindSet() then
                repeat
                    if not TempReplacementLine.Get(ReplacementLine.RecordId) then begin
                        TempReplacementLine := ReplacementLine;
                        TempReplacementLine.Insert();
                    end;
                until ReplacementLine.Next() = 0;
        until ReplacementAssignmentForDataFile.Next() = 0;
        TempReplacementLineNew.Copy(TempReplacementLine, true);
        Found := TempReplacementLineNew.FindFirst();
    end;

    local procedure FindArgumentFieldNumbers(var ArgumentFieldNumbers: List of [Integer]; var ReplacementAssignmentForDataFile: Record DMTReplacement temporary) Found: Boolean
    var
        CompareFieldNo, i : Integer;
    begin
        Clear(ArgumentFieldNumbers);
        if not ReplacementAssignmentForDataFile.FindSet() then
            exit(false);
        repeat
            for i := 1 to 2 do begin
                case i of
                    1:
                        CompareFieldNo := ReplacementAssignmentForDataFile."Compare Value 1 Field No.";
                    2:
                        CompareFieldNo := ReplacementAssignmentForDataFile."Compare Value 2 Field No.";
                end;
                if CompareFieldNo <> 0 then
                    if not ArgumentFieldNumbers.Contains(CompareFieldNo) then
                        ArgumentFieldNumbers.Add(CompareFieldNo);
            end;
        until ReplacementAssignmentForDataFile.Next() = 0;
        Found := ArgumentFieldNumbers.Count > 0;
    end;

    local procedure ReadCompareFields(var ArgumentFieldRefArray: array[16] of FieldRef; var SourceRef: RecordRef; ArgumentFieldNumbers: List of [Integer])
    var
        i: Integer;
    begin
        Clear(ArgumentFieldRefArray);
        if ArgumentFieldNumbers.Count > ArrayLen(ArgumentFieldRefArray) then
            Error('ReadArgumentFieldValues: Too many arguments for FieldRefArray');
        for i := 1 to ArgumentFieldNumbers.Count do begin
            ArgumentFieldRefArray[i] := SourceRef.Field(ArgumentFieldNumbers.Get(i));
        end;
    end;

    local procedure FindNewValueFields(var NewValueFieldArray: array[16] of FieldRef; var NewValueFieldNumbers: List of [Integer]; CompareFieldValueArray: array[16] of FieldRef; CompareFieldNumbers: List of [Integer]; var TempReplacementLine: Record DMTReplacement temporary; TargetTableID: Integer) Found: Boolean
    var
        ReplacementHeader: Record DMTReplacement;
        DummyTargetRef: RecordRef;
        IsMatch: Boolean;
        ArrayPos: Integer;
    begin
        Clear(NewValueFieldArray);
        Clear(NewValueFieldNumbers);
        DummyTargetRef.Open(TargetTableID, true);
        TempReplacementLine.FindSet();
        repeat
            Clear(IsMatch);
            TempReplacementLine.TestField(LineType, TempReplacementLine.LineType::Line);
            // Get Header
            ReplacementHeader.Get(TempReplacementLine.LineType::Header, TempReplacementLine."Replacement Code", 0);
            // Get Assignment
            ReplacementAssignmentForDataFileGlobal.reset();
            ReplacementAssignmentForDataFileGlobal.SetRange("Replacement Code", TempReplacementLine."Replacement Code");
            ReplacementAssignmentForDataFileGlobal.FindFirst();

            case ReplacementHeader."No. of Compare Values" of
                ReplacementHeader."No. of Compare Values"::"1":
                    begin
                        IsMatch := format(CompareFieldValueArray[1].Value) = TempReplacementLine."Comp.Value 1";
                    end;
                ReplacementHeader."No. of Compare Values"::"2":
                    begin
                        IsMatch := format(CompareFieldValueArray[1].Value) = TempReplacementLine."Comp.Value 1";
                        IsMatch := IsMatch and (format(CompareFieldValueArray[2].Value) = TempReplacementLine."Comp.Value 2");
                    end;
                else
                    error('unhandled case');
            end;

            if IsMatch then begin
                case ReplacementHeader."No. of Values to modify" of
                    ReplacementHeader."No. of Values to modify"::"1":
                        begin
                            ReplacementAssignmentForDataFileGlobal.Testfield("New Value 1 Field No.");
                            NewValueFieldNumbers.Add(ReplacementAssignmentForDataFileGlobal."New Value 1 Field No.");
                            StoreArrayPosForTargetFieldNo(ReplacementAssignmentForDataFileGlobal."New Value 1 Field No.");
                            ArrayPos := GetArrayPosByTargetFieldNo(ReplacementAssignmentForDataFileGlobal."New Value 1 Field No.");
                            NewValueFieldArray[ArrayPos] := DummyTargetRef.Field(ReplacementAssignmentForDataFileGlobal."New Value 1 Field No.");
                            NewValueFieldArray[ArrayPos].Value(TempReplacementLine."New Value 1");
                        end;
                    ReplacementHeader."No. of Values to modify"::"2":
                        begin
                            ReplacementAssignmentForDataFileGlobal.Testfield("New Value 1 Field No.");
                            NewValueFieldNumbers.Add(ReplacementAssignmentForDataFileGlobal."New Value 1 Field No.");
                            StoreArrayPosForTargetFieldNo(ReplacementAssignmentForDataFileGlobal."New Value 1 Field No.");
                            ArrayPos := GetArrayPosByTargetFieldNo(ReplacementAssignmentForDataFileGlobal."New Value 1 Field No.");
                            NewValueFieldArray[ArrayPos] := DummyTargetRef.Field(ReplacementAssignmentForDataFileGlobal."New Value 1 Field No.");
                            NewValueFieldArray[ArrayPos].Value(TempReplacementLine."New Value 1");

                            ReplacementAssignmentForDataFileGlobal.Testfield("New Value 2 Field No.");
                            NewValueFieldNumbers.Add(ReplacementAssignmentForDataFileGlobal."New Value 2 Field No.");
                            StoreArrayPosForTargetFieldNo(ReplacementAssignmentForDataFileGlobal."New Value 2 Field No.");
                            ArrayPos := GetArrayPosByTargetFieldNo(ReplacementAssignmentForDataFileGlobal."New Value 2 Field No.");
                            NewValueFieldArray[ArrayPos] := DummyTargetRef.Field(ReplacementAssignmentForDataFileGlobal."New Value 2 Field No.");
                            NewValueFieldArray[ArrayPos].Value(TempReplacementLine."New Value 2");
                        end;
                    else
                        error('unhandled case');
                end;
            end;
        until TempReplacementLine.Next() = 0;
        Found := NewValueFieldNumbers.Count > 0;
    end;

    local procedure LoadFieldMappingForMatchingTableRelations(var TempFieldMappingFound: Record DMTFieldMapping temporary; RelatedTableID: Integer; TableNoFilter: Text) NoOfLinesFound: Integer
    var
        FieldMapping: Record DMTFieldMapping;
        TableRelationsMetadata: Record "Table Relations Metadata";
        TempFieldMapping: Record DMTFieldMapping temporary;
    begin
        TableRelationsMetadata.SetRange("Condition Field No.", 0); // else Conditions (e.g.Bin) and tablerelation=Tablename conditions
        TableRelationsMetadata.SetFilter("Table ID", TableNoFilter);
        TableRelationsMetadata.SetRange("Related Table ID", RelatedTableID);
        TableRelationsMetadata.SetFilter("Related Field No.", '<>2000000000'); // no systemid relations
        // TableRelationsMetadata.SetRange("Related Field No.", 1);
        // Collect Matching Fields
        if TableRelationsMetadata.FindSet() then
            repeat
                FieldMapping.Reset();
                FieldMapping.SetRange("Target Table ID", TableRelationsMetadata."Table ID");
                FieldMapping.SetRange("Target Field No.", TableRelationsMetadata."Field No.");
                if FieldMapping.FindSet() then
                    repeat
                        TempFieldMapping := FieldMapping;
                        if TempFieldMapping.Insert() then;
                    until FieldMapping.Next() = 0;
            until TableRelationsMetadata.Next() = 0;
        TempFieldMappingFound.Copy(TempFieldMapping, true);
        NoOfLinesFound := TempFieldMappingFound.Count;
    end;

    internal procedure proposeAssignments(ReplacementHeader: Record DMTReplacement)
    var
        TempFieldMappingFound: array[2] of Record DMTFieldMapping temporary;
        DataFile: Record DMTDataFile;
        ReplacementAssignments: Record DMTReplacement;
        TableNoFilter: Text;
    begin
        ReplacementHeader.TestField(LineType, ReplacementHeader.LineType::Header);

        // Search Relations in Target Fields
        DataFile.SetFilter(ID, '48|106'); //debug
        if DataFile.FindSet(false, false) then
            repeat
                TableNoFilter += StrSubstNo('%1|', DataFile."Target Table ID");
            until DataFile.Next() = 0;
        TableNoFilter := TableNoFilter.TrimEnd('|');
        // Filter Relations
        case ReplacementHeader."No. of Values to modify" of
            ReplacementHeader."No. of Values to modify"::"1":
                begin
                    ReplacementHeader.Testfield("Rel.to Table ID (New Val.1)");
                    LoadFieldMappingForMatchingTableRelations(TempFieldMappingFound[1], ReplacementHeader."Rel.to Table ID (New Val.1)", TableNoFilter);
                end;
            ReplacementHeader."No. of Values to modify"::"2":
                begin
                    ReplacementHeader.Testfield("Rel.to Table ID (New Val.1)");
                    LoadFieldMappingForMatchingTableRelations(TempFieldMappingFound[1], ReplacementHeader."Rel.to Table ID (New Val.1)", TableNoFilter);
                    ReplacementHeader.Testfield("Rel.to Table ID (New Val.2)");
                    LoadFieldMappingForMatchingTableRelations(TempFieldMappingFound[2], ReplacementHeader."Rel.to Table ID (New Val.2)", TableNoFilter);
                end;
            else
                Error('Unhandled Option');
        end;

        // Add Assignments if match for all fields exist
        DataFile.Reset();
        DataFile.SetFilter(ID, '48|106'); //debug
        if DataFile.FindSet() then
            repeat
                ReplacementAssignments.Reset();
                ReplacementAssignments.SetRange("Replacement Code", ReplacementHeader."Replacement Code");
                if not ReplacementAssignments.filterAssignmentFor(DataFile) then begin
                    case ReplacementHeader."No. of Values to modify" of
                        ReplacementHeader."No. of Values to modify"::"1":
                            begin
                                // Find Matching FieldMapping with Relations
                                TempFieldMappingFound[1].Reset();
                                TempFieldMappingFound[1].SetRange("Data File ID", DataFile.ID);
                                TempFieldMappingFound[1].SetRange("Target Table ID", DataFile."Target Table ID");
                                if TempFieldMappingFound[1].FindFirst() then begin
                                    Clear(ReplacementAssignments);
                                    ReplacementAssignments.LineType := ReplacementAssignments.LineType::Assignment;
                                    ReplacementAssignments."Replacement Code" := ReplacementHeader."Replacement Code";
                                    ReplacementAssignments."Data File ID" := DataFile.ID;
                                    ReplacementAssignments."Target Table ID" := DataFile."Target Table ID";
                                    ReplacementAssignments."Compare Value 1 Field No." := TempFieldMappingFound[1]."Source Field No.";
                                    ReplacementAssignments."New Value 1 Field No." := TempFieldMappingFound[1]."Target Field No.";
                                    ReplacementAssignments.Insert(true);
                                    Commit();
                                end;
                            end;
                        ReplacementHeader."No. of Values to modify"::"2":
                            begin
                                // Find Matching FieldMapping with Relations
                                TempFieldMappingFound[1].Reset();
                                TempFieldMappingFound[1].SetRange("Data File ID", DataFile.ID);
                                TempFieldMappingFound[1].SetRange("Target Table ID", DataFile."Target Table ID");
                                TempFieldMappingFound[2].Reset();
                                TempFieldMappingFound[2].SetRange("Data File ID", DataFile.ID);
                                TempFieldMappingFound[2].SetRange("Target Table ID", DataFile."Target Table ID");
                                if TempFieldMappingFound[1].FindFirst() and TempFieldMappingFound[2].FindFirst() then begin
                                    Clear(ReplacementAssignments);
                                    ReplacementAssignments.LineType := ReplacementAssignments.LineType::Assignment;
                                    ReplacementAssignments."Replacement Code" := ReplacementHeader."Replacement Code";
                                    ReplacementAssignments."Data File ID" := DataFile.ID;
                                    ReplacementAssignments."Target Table ID" := DataFile."Target Table ID";
                                    ReplacementAssignments."Compare Value 1 Field No." := TempFieldMappingFound[1]."Source Field No.";
                                    ReplacementAssignments."New Value 1 Field No." := TempFieldMappingFound[1]."Target Field No.";
                                    if ReplacementHeader."No. of Compare Values" in [ReplacementHeader."No. of Compare Values"::"2"] then
                                        ReplacementAssignments."Compare Value 2 Field No." := TempFieldMappingFound[2]."Source Field No.";
                                    ReplacementAssignments."New Value 2 Field No." := TempFieldMappingFound[2]."Target Field No.";
                                    ReplacementAssignments.Insert(true);
                                    Commit();
                                end;
                            end;
                        else
                            Error('Unhandled Option');
                    end;
                end;
            until DataFile.Next() = 0

    end;

    procedure StoreArrayPosForTargetFieldNo(TargetFieldNo: Integer)
    begin
        // Stack new field nos
        if not FieldPosArrayPosMappingGlobal.ContainsKey(TargetFieldNo) then
            FieldPosArrayPosMappingGlobal.Add(TargetFieldNo, FieldPosArrayPosMappingGlobal.Values.Count + 1);
    end;

    procedure GetArrayPosByTargetFieldNo(TargetFieldNo: Integer) ArrayPos: Integer
    begin
        ArrayPos := FieldPosArrayPosMappingGlobal.Get(TargetFieldNo);
    end;


    var
        ReplacementAssignmentForDataFileGlobal, ReplacementLineGlobal : Record DMTReplacement temporary;
        NewValueFieldArrayGlobal: array[16] of FieldRef;
        HasReplacements, IsInitialized : Boolean;
        NewValueFieldNumbersGlobal: List of [Integer];
        FieldPosArrayPosMappingGlobal: Dictionary of [Integer, Integer];

}