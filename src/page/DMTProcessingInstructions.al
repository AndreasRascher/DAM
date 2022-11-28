page 110017 "DMTProcessingInstructions"
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
                    Message('ToDo');
                end;
            }
            repeater("FilterList")
            {
                Caption = 'Filter', Comment = 'Filter';
                Visible = IsSourceTableFilterView;
                field("FieldCaption"; Rec."Source Field Caption") { ApplicationArea = All; }
                field("FixedValue"; Rec.Comment) { ApplicationArea = All; }
            }

            repeater("FixedValuesList")
            {
                Caption = 'Fixed Values';
                Visible = IsFixedValueView;
                field("FilterFieldCaption"; Rec."Source Field Caption") { ApplicationArea = All; }
                field("FilterValue"; Rec.Comment) { ApplicationArea = All; Caption = 'Filter'; }

            }
        }
    }

    internal procedure InitFactBoxAsSourceTableFilter(ProcessingPlan: Record DMTProcessingPlan)
    var
        DMTFieldMapping: Record DMTFieldMapping;

    begin
        if ProcessingPlan."Line Type" = ProcessingPlan."Line Type"::Group then begin
            IsSourceTableFilterView := false;
            Rec.DeleteAll();
            exit;
        end;
        IsSourceTableFilterView := true;
        DMTFieldMapping.SetRange("Data File ID", ProcessingPlan.DataFileID);
        DMTFieldMapping.CopyToTemp(Rec);
        CurrPage.Update(false);
    end;

    internal procedure InitFactBoxAsFixedValueView(ProcessingPlan: Record DMTProcessingPlan)
    var
        DMTFieldMapping: Record DMTFieldMapping;
    begin
        if ProcessingPlan."Line Type" = ProcessingPlan."Line Type"::Group then begin
            IsFixedValueView := false;
            Rec.DeleteAll();
            exit;
        end;
        IsFixedValueView := true;
        DMTFieldMapping.SetRange("Data File ID", ProcessingPlan.DataFileID);
        DMTFieldMapping.CopyToTemp(Rec);
        CurrPage.Update(false);
    end;

    var
        [InDataSet]
        IsSourceTableFilterView, IsFixedValueView : Boolean;
}

