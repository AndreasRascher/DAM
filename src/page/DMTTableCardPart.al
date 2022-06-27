page 81132 "DMTTableCardPart"
{
    PageType = ListPart;
    SourceTable = "DMTField";
    InsertAllowed = false;
    SourceTableView = sorting("Validation Order");

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Processing Action"; rec."Processing Action") { ApplicationArea = all; }
                field("To Field No."; Rec."To Field No.") { Visible = false; ApplicationArea = All; }
                field("To Field Caption"; Rec."To Field Caption") { ApplicationArea = All; StyleExpr = LineStyleExpr; }
                field("From Field Caption"; Rec."From Field Caption")
                {
                    Visible = not ShowGenBufferTableColumns;
                    HideValue = HideFromFieldInfo;
                    ApplicationArea = All;
                }
                field("From Field Caption (GenBufferTable)"; Rec."From Field Caption (GenBuff)")
                {
                    Visible = ShowGenBufferTableColumns;
                    HideValue = HideFromFieldInfo;
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        RunSelectSourceFieldDialog();
                    end;
                }
                field("From Field No."; Rec."From Field No.") { HideValue = HideFromFieldInfo; ApplicationArea = All; }
                field("Ignore Validation Error"; Rec."Ignore Validation Error") { ApplicationArea = All; }
                field("Trgt.Field Type"; Rec."To Field Type") { Visible = false; ApplicationArea = All; }
                field("From Field Type"; Rec."From Field Type") { HideValue = HideFromFieldInfo; Visible = false; ApplicationArea = All; }
                field("Validate Value"; Rec."Validate Value") { ApplicationArea = All; }
                field("Use Try Function"; Rec."Use Try Function") { ApplicationArea = All; }
                field("Fixed Value"; Rec."Fixed Value") { ApplicationArea = All; }
                field(ReplacementsCode; Rec."Replacements Code") { ApplicationArea = All; }
                field(ValidationOrder; Rec."Validation Order") { ApplicationArea = All; Visible = false; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(InitTargetFields)
            {
                Caption = 'Init Target Fields', comment = 'Feldliste initialisieren';
                ApplicationArea = All;
                Image = SuggestField;


                trigger OnAction()
                var
                    DMTFields: Record "DMTField";
                    DMTTable: Record DMTTable;
                begin
                    DMTTable.Get(Rec.GetRangeMin(rec."To Table No."));
                    DMTFields.InitForTargetTable(DMTTable);
                end;
            }
            action(ProposeMatchingFields)
            {
                Caption = 'Popose Matching Fields', comment = 'Feldzuordnung vorschlagen';
                ApplicationArea = All;
                Image = SuggestField;

                trigger OnAction()
                var
                    DMTFields: Record "DMTField";
                    DMTTable: Record DMTTable;
                begin
                    DMTTable.Get(Rec.GetRangeMin(rec."To Table No."));
                    DMTFields.ProposeMatchingTargetFields(DMTTable);
                    DMTFields.ProposeValidationRules(DMTTable);
                end;
            }
            group(ChangeValidationOrder)
            {
                Image = Allocate;
                Caption = 'Change Validation Order', Comment = 'Validierungsreihenfolge ändern';
                action(MoveSelectedUp)
                {
                    ApplicationArea = All;
                    Caption = 'Up', Comment = 'Oben';
                    Scope = Repeater;
                    Image = MoveUp;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        MoveSelectedLines(Direction::Up);
                    end;
                }
                action(MoveSelectedDown)
                {
                    ApplicationArea = All;
                    Caption = 'Down', Comment = 'Unten';
                    Scope = Repeater;
                    Image = MoveDown;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        MoveSelectedLines(Direction::Down);
                    end;
                }
                action(MoveSelectedToTop)
                {
                    ApplicationArea = All;
                    Caption = 'Top', Comment = 'Anfang';
                    Scope = Repeater;
                    Image = ChangeTo;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        MoveSelectedLines(Direction::Top);
                    end;
                }
                action(MoveSelectedToEnd)
                {
                    ApplicationArea = All;
                    Caption = 'Bottom', Comment = 'Ende';
                    Scope = Repeater;
                    Image = Apply;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        MoveSelectedLines(Direction::Bottom);
                    end;
                }
            }
        }
    }

    procedure GetSelection(var TempDMTField: Record DMTField temporary) HasLines: Boolean
    var
        DMTField: Record DMTField;
    begin
        Clear(TempDMTField);
        if TempDMTField.IsTemporary then TempDMTField.DeleteAll();
        CurrPage.SetSelectionFilter(DMTField);
        if not DMTField.MarkedOnly then begin
            DMTField := Rec;
            DMTField.Mark(true);
            DMTField.MarkedOnly(true);
        end;
        DMTField.CopyToTemp(TempDMTField);
        HasLines := TempDMTField.FindFirst();
    end;

    local procedure MoveSelectedLines(Direction: Option Up,Down,Top,Bottom)
    var
        DMTField: Record DMTField;
        TempFieldSelection, TempDMTField : Record DMTField temporary;
        i: Integer;
        RefPos: Integer;
    begin
        If not GetSelection(TempFieldSelection) then
            exit;

        DMTField.SetRange("To Table No.", TempFieldSelection."To Table No.");
        DMTField.SetCurrentKey("Validation Order");
        DMTField.CopyToTemp(TempDMTField);

        TempDMTField.SetCurrentKey("Validation Order");
        case Direction of
            Direction::Bottom:
                begin
                    TempDMTField.FindLast();
                    RefPos := TempDMTField."Validation Order";
                    TempFieldSelection.FindSet();
                    repeat
                        i += 1;
                        TempDMTField.Get(TempFieldSelection.RecordId);
                        TempDMTField."Validation Order" := RefPos + i * 10000;
                        TempDMTField.Modify();
                    until TempFieldSelection.Next() = 0;
                end;
            Direction::Top:
                begin
                    TempDMTField.FindFirst();
                    RefPos := TempDMTField."Validation Order";
                    TempFieldSelection.find('+');
                    repeat
                        i += 1;
                        TempDMTField.Get(TempFieldSelection.RecordId);
                        TempDMTField."Validation Order" := RefPos - i * 10000;
                        TempDMTField.Modify();
                    until TempFieldSelection.Next(-1) = 0;
                end;
            Direction::Up:
                begin
                    TempFieldSelection.FindSet();
                    repeat
                        TempDMTField.Get(TempFieldSelection.RecordId);
                        RefPos := TempDMTField."Validation Order";
                        if TempDMTField.Next(-1) <> 0 then begin
                            i := TempDMTField."Validation Order";
                            TempDMTField."Validation Order" := RefPos;
                            TempDMTField.Modify();
                            TempDMTField.Get(TempFieldSelection.RecordId);
                            TempDMTField."Validation Order" := i;
                            TempDMTField.Modify();
                        end;
                    until TempFieldSelection.Next() = 0;
                end;
            Direction::Down:
                begin
                    TempFieldSelection.SetCurrentKey("Validation Order");
                    TempFieldSelection.Ascending(false);
                    TempFieldSelection.FindSet();
                    repeat
                        TempDMTField.Get(TempFieldSelection.RecordId);
                        RefPos := TempDMTField."Validation Order";
                        if TempDMTField.Next(1) <> 0 then begin
                            i := TempDMTField."Validation Order";
                            TempDMTField."Validation Order" := RefPos;
                            TempDMTField.Modify();
                            TempDMTField.Get(TempFieldSelection.RecordId);
                            TempDMTField."Validation Order" := i;
                            TempDMTField.Modify();
                        end;
                    until TempFieldSelection.Next() = 0;
                end;
        end;
        TempDMTField.Reset();
        TempDMTField.SetCurrentKey("Validation Order");
        TempDMTField.FindSet();
        Clear(i);
        repeat
            i += 1;
            DMTField.Get(TempDMTField.RecordId);
            DMTField."Validation Order" := i * 10000;
            DMTField.Modify(false);
        until TempDMTField.Next() = 0;
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateControlVariables();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UpdateControlVariables();
    end;

    procedure UpdateControlVariables()
    var
        DMTErrorLog: Record DMTErrorLog;
    begin
        HideFromFieldInfo := Rec."Fixed Value" <> '';
        LineStyleExpr := '';
        if DMTErrorLog.ErrorsExistFor(Rec, true) then
            LineStyleExpr := 'Attention';
    end;

    internal procedure SetBufferTableType(BufferTableType: Option)
    var
        DMTTable: Record DMTTable;
    begin
        ShowGenBufferTableColumns := BufferTableType = DMTTable.BufferTableType::"Generic Buffer Table for all Files";
        CurrPage.Update();
    end;

    procedure RunSelectSourceFieldDialog()
    var
        GenBuffTable: Record DMTGenBuffTable;
        DMTTable: Record DMTTable;
        DMTField2: Record DMTField;
        BuffTableCaptions: Dictionary of [Integer, Text];
        Choices: Text;
        SelectedFieldNo: Integer;
        FieldCaption: Text;
    begin
        DMTTable.Get(Rec."To Table No.");
        GenBuffTable.GetColCaptionForImportedFile(DMTTable, BuffTableCaptions);
        foreach FieldCaption in BuffTableCaptions.Values do begin
            Choices += FieldCaption + ',';
        end;
        SelectedFieldNo := StrMenu(Choices);
        if SelectedFieldNo <> 0 then begin
            DMTField2 := Rec;
            DMTField2."From Field No." := SelectedFieldNo;
            DMTField2."From Field Caption (GenBuff)" := CopyStr(BuffTableCaptions.Get(SelectedFieldNo), 1, MaxStrLen(DMTField2."From Field Caption (GenBuff)"));
            DMTField2.Modify();
        end;
    end;

    Var
        [InDataSet]
        HideFromFieldInfo, ShowGenBufferTableColumns : Boolean;
        [InDataSet]
        LineStyleExpr: text;
}