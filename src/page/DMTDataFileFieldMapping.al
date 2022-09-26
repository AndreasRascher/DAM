page 110028 DMTFieldMapping
{
    PageType = ListPart;
    SourceTable = DMTFieldMapping;
    InsertAllowed = false;
    SourceTableView = sorting("Validation Order");

    layout
    {
        area(Content)
        {
            repeater(repeater)
            {
                field("Processing Action"; rec."Processing Action") { ApplicationArea = all; }
                field("To Field No."; Rec."Target Field No.") { Visible = false; ApplicationArea = All; Editable = false; }
                field("To Field Caption"; Rec."Target Field Caption") { ApplicationArea = All; StyleExpr = LineStyleExpr; Editable = false; }
                field("From Field Caption"; Rec."Source Field Caption")
                {
                    HideValue = IsFixedValue;
                    ApplicationArea = All;
                }
                field("Target Field Name"; Rec."Target Field Name")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("From Field No."; Rec."Source Field No.") { LookupPageId = DMTFieldLookup; HideValue = IsFixedValue; ApplicationArea = All; }
                field("Ignore Validation Error"; Rec."Ignore Validation Error") { ApplicationArea = All; }
                field("Validation Type"; "Validation Type") { ApplicationArea = All; }
                field("Use Try Function"; Rec."Use Try Function") { ApplicationArea = All; }
                field("Fixed Value"; Rec."Fixed Value") { ApplicationArea = All; }
                field(ReplacementsCode; Rec."Replacements Code") { ApplicationArea = All; }
                field(ValidationOrder; Rec."Validation Order") { ApplicationArea = All; Visible = false; }
                field(Comment; Rec.Comment) { ApplicationArea = All; }
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
                begin
                    DataFilePageAction.InitFieldMapping(Rec.GetRangeMin("Data File ID"));
                end;
            }
            action(ProposeMatchingFields)
            {
                Caption = 'Popose Matching Fields', comment = 'Feldzuordnung vorschlagen';
                ApplicationArea = All;
                Image = SuggestField;
                trigger OnAction()
                begin
                    DataFilePageAction.ProposeMatchingFields(Rec.GetRangeMin("Data File ID"));
                end;
            }
            group(Lines)
            {
                Caption = 'Lines', Comment = 'Zeilen';
                action(FieldMapping_SetValidateFieldToAlways)
                {
                    Caption = 'Set Field Validate to always', Comment = 'Validierungsart auf Immer setzen';
                    ApplicationArea = All;
                    Image = SetupLines;
                    trigger OnAction()
                    begin
                        GetSelection(TempFieldMapping_Selected);
                        DataFilePageAction.FieldMapping_SetValidateField(TempFieldMapping_Selected, Enum::DMTFieldValidationType::AlwaysValidate);
                    end;
                }
                action(DMTField_SetValidateFieldToFalse)
                {
                    Caption = 'Set Validation Type to assign without validate', Comment = 'Validierungsart auf Zuweisen ohne validieren setzen';
                    ApplicationArea = All;
                    Image = SetupLines;
                    trigger OnAction()
                    begin
                        GetSelection(TempFieldMapping_Selected);
                        DataFilePageAction.FieldMapping_SetValidateField(TempFieldMapping_Selected, Enum::DMTFieldValidationType::AssignWithoutValidate);
                    end;
                }
            }
            group(ChangeValidationOrder)
            {
                Image = Allocate;
                Caption = 'Change Validation Order', Comment = 'Validierungsreihenfolge ändern';
                action(MoveSelectedUp)
                {
                    ApplicationArea = All;
                    Caption = 'Up', Comment = 'Oben';
                    // Scope = Repeater;
                    Image = MoveUp;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        if GetSelection(TempFieldMapping_Selected) then
                            DataFilePageAction.MoveSelectedLines(TempFieldMapping_Selected, Direction::Up);
                    end;
                }
                action(MoveSelectedDown)
                {
                    ApplicationArea = All;
                    Caption = 'Down', Comment = 'Unten';
                    // Scope = Repeater;
                    Image = MoveDown;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        if GetSelection(TempFieldMapping_Selected) then
                            DataFilePageAction.MoveSelectedLines(TempFieldMapping_Selected, Direction::Down);
                    end;
                }
                action(MoveSelectedToTop)
                {
                    ApplicationArea = All;
                    Caption = 'Top', Comment = 'Anfang';
                    // Scope = Repeater;
                    Image = ChangeTo;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        if GetSelection(TempFieldMapping_Selected) then
                            DataFilePageAction.MoveSelectedLines(TempFieldMapping_Selected, Direction::Top);
                    end;
                }
                action(MoveSelectedToEnd)
                {
                    ApplicationArea = All;
                    Caption = 'Bottom', Comment = 'Ende';
                    // Scope = Repeater;
                    Image = Apply;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        if GetSelection(TempFieldMapping_Selected) then
                            DataFilePageAction.MoveSelectedLines(TempFieldMapping_Selected, Direction::Bottom);
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        IsFixedValue := Rec."Processing Action" = Rec."Processing Action"::FixedValue;
    end;

    procedure GetSelection(var FieldMapping_SELCTED: Record DMTFieldMapping temporary) HasLines: Boolean
    var
        FieldMapping: Record DMTFieldMapping;
        Debug: Integer;
    begin
        Clear(FieldMapping_SELCTED);
        if FieldMapping_SELCTED.IsTemporary then FieldMapping_SELCTED.DeleteAll();
        Debug := Rec.Count;
        FieldMapping.Copy(rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(FieldMapping);
        Debug := FieldMapping.Count;
        FieldMapping.CopyToTemp(FieldMapping_SELCTED);
        HasLines := FieldMapping_SELCTED.FindFirst();
    end;


    var
        TempFieldMapping_Selected: Record DMTFieldMapping temporary;
        DataFilePageAction: Codeunit DMTDataFilePageAction;
        IsFixedValue: Boolean;
        LineStyleExpr: Text;
}