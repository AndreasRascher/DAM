page 110017 "DMTProcessInstructionFactBox"
{
    Caption = 'Processing Instructions';
    PageType = ListPart;
    SourceTable = DMTFieldMapping;
    SourceTableTemporary = true;
    layout
    {
        area(content)
        {

            field(Edit; 'Edit')
            {
                ApplicationArea = All;
                ShowCaption = false;
                trigger OnDrillDown()
                begin
                    if IsSourceTableFilterView then
                        CurrProcessingPlan.EditSourceTableFilter();
                    if IsFixedValueView then
                        CurrProcessingPlan.EditDefaultValues();
                    ReloadPageContent();
                    CurrPage.Update(false);
                end;
            }
            repeater("FilterList")
            {
                Caption = 'Filter', Comment = 'Filter';
                Visible = IsSourceTableFilterView;
                field("FieldCaption"; Rec."Source Field Caption") { ApplicationArea = All; }
                field(FixedValue; Rec.Comment) { ApplicationArea = All; }
            }

            repeater("FixedValuesList")
            {
                Caption = 'Fixed Values';
                Visible = IsFixedValueView;
                field(FilterFieldCaption; Rec."Source Field Caption") { ApplicationArea = All; }
                field(FilterValue; Rec.Comment) { ApplicationArea = All; Caption = 'Filter'; }

            }
        }
    }

    internal procedure InitFactBoxAsSourceTableFilter(ProcessingPlan: Record DMTProcessingPlan)
    begin
        if ProcessingPlan.Type = ProcessingPlan.Type::Group then begin
            IsSourceTableFilterView := false;
            Rec.DeleteAll();
            exit;
        end;
        IsSourceTableFilterView := true;
        CurrProcessingPlan := ProcessingPlan;
        CurrProcessingPlan.ConvertSourceTableFilterToFieldLines(Rec);
        CurrPage.Update(false);
    end;

    internal procedure InitFactBoxAsFixedValueView(ProcessingPlan: Record DMTProcessingPlan)
    var
        DMTFieldMapping: Record DMTFieldMapping;
    begin
        if ProcessingPlan.Type = ProcessingPlan.Type::Group then begin
            IsFixedValueView := false;
            Rec.DeleteAll();
            exit;
        end;
        IsFixedValueView := true;
        DMTFieldMapping.SetRange("Data File ID", ProcessingPlan.ID);
        DMTFieldMapping.CopyToTemp(Rec);
        Rec.SetFilter(Comment, '<>''''');
        CurrPage.Update(false);
        CurrProcessingPlan := ProcessingPlan;
    end;

    procedure ReloadPageContent()
    begin
        if Rec.IsTemporary then begin
            Rec.Reset();
            Rec.DeleteAll();
        end;
        if IsFixedValueView then begin
            CurrProcessingPlan.get(CurrProcessingPlan.RecordId);
            CurrProcessingPlan.ConvertDefaultValuesViewToFieldLines(Rec);
        end;
        if IsSourceTableFilterView then begin
            CurrProcessingPlan.get(CurrProcessingPlan.RecordId);
            CurrProcessingPlan.ConvertSourceTableFilterToFieldLines(Rec);
        end;
        CurrPage.Update();
    end;

    var
        CurrProcessingPlan: Record DMTProcessingPlan;
        [InDataSet]
        IsFixedValueView, IsSourceTableFilterView : Boolean;
}

