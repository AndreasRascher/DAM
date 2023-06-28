page 73024 DMTReplacementCard
{
    Caption = 'DMT Replacement Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = DMTReplacement;
    DataCaptionExpression = Rec."Replacement Code" + ' ' + Rec.Description;
    SourceTableView = sorting(LineType, "Replacement Code", "Line No.") where(LineType = const(Header), "Line No." = const(0));

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Code; Rec."Replacement Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; Importance = Promoted; }

            }
            group("Field Setup")
            {
                Caption = 'Field Setup';
                group(InnerFieldSetup)
                {
                    ShowCaption = false;
                    grid(NoOfValuesGrid)
                    {
                        ShowCaption = false;
                        GridLayout = Columns;
                        group(NoOfValuesGrid_Col1)
                        {
                            ShowCaption = false;
                            field("No. of Compare Values"; Rec."No. of Compare Values")
                            {
                                ApplicationArea = All;
                                Importance = Promoted;
                                trigger OnValidate()
                                begin
                                    EnableControls(xRec, Rec);
                                    UpdatePageParts(xRec, Rec);
                                end;
                            }
                        }
                        group(NoOfValuesGrid_Col2)
                        {
                            ShowCaption = false;
                            field("No. of fields to modify"; Rec."No. of Values to modify")
                            {
                                ApplicationArea = All;
                                Importance = Promoted;
                                trigger OnValidate()
                                begin
                                    EnableControls(xRec, Rec);
                                    UpdatePageParts(xRec, Rec);
                                end;
                            }
                        }
                    }
                    grid(FieldDefGrid)
                    {
                        ShowCaption = false;
                        GridLayout = Rows;
                        group(GridLabels)
                        {
                            Caption = ' ', Locked = true;
                            label(FieldCaption) { Caption = 'Caption'; }
                            label("Rel.to Table ID") { Caption = 'Rel.to Table ID'; }
                            label("Rel.to Table Name") { Caption = 'Rel.to Table'; }
                        }
                        group(FromField1Group)
                        {
                            Caption = 'Compare Value 1';
                            field("Comp.Fld.1 Caption"; Rec."Comp.Val.1 Caption") { ApplicationArea = All; ShowCaption = false; }
                            // field("Rel.to Table ID (Comp.Val.1)"; Rec."Rel.to Table ID (Comp.Val.1)") { ApplicationArea = All; ShowCaption = false; }
                            // field("Rel.to Table Cpt.(Comp.Val.1)"; Rec."Rel.to Table Cpt.(Comp.Val.1)") { ApplicationArea = All; ShowCaption = false; }

                        }
                        group(FromField2Group)
                        {
                            Caption = 'Compare Value 2';
                            Visible = CompareValue2_Visible;
                            field("Comp.Fld.2 Caption"; Rec."Comp.Val.2 Caption") { ApplicationArea = All; ShowCaption = false; }
                        }
                        group(ToFieldGroup1)
                        {
                            Caption = 'New Value 1';
                            field("New Value 1 Caption"; Rec."New Value 1 Caption") { ApplicationArea = All; ShowCaption = false; }
                            field("Rel.to Table ID (New Val.1)"; Rec."Rel.to Table ID (New Val.1)") { ApplicationArea = All; ShowCaption = false; }
                            field("Rel.to Table Cpt.(New Val.1)"; Rec."Rel.to Table Cpt.(New Val.1)") { ApplicationArea = All; ShowCaption = false; }
                        }
                        group(ToFieldGroup2)
                        {
                            Visible = NewValue2_Visible;
                            Caption = 'New Value 2';
                            field("New Value 2 Caption"; Rec."New Value 2 Caption") { ApplicationArea = All; ShowCaption = false; }
                            field("Rel.to Table ID (New Val.2)"; Rec."Rel.to Table ID (New Val.2)") { ApplicationArea = All; ShowCaption = false; }
                            field("Rel.to Table Cpt.(New Val.2)"; Rec."Rel.to Table Cpt.(New Val.2)") { ApplicationArea = All; ShowCaption = false; }

                        }
                    }
                }
            }
            part(Rules; DMTReplacementRulesPart)
            {
                SubPageLink = "Replacement Code" = field("Replacement Code");
                UpdatePropagation = SubPart;
            }
            part(Assignments; DMTReplacementAssigmentsPart)
            {
                SubPageLink = "Replacement Code" = field("Replacement Code"), LineType = const(Assignment);
                ApplicationArea = All;
                // Editable = false;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ProposeAssignments)
            {
                ApplicationArea = All;
                Image = Suggest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Propose Assignments', Comment = 'de-DE=Zuordnung vorschlagen';
                trigger OnAction()
                var
                    ReplacementsMgt: Codeunit DMTReplacementsMgt;
                begin
                    if Rec."Replacement Code" <> '' then
                        CurrPage.SaveRecord();
                    ReplacementsMgt.proposeAssignments(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    internal procedure EnableControls(ReplacementOld: Record DMTReplacement; Replacement: Record DMTReplacement)
    begin
        if Replacement.IsEqual(ReplacementOld) then
            exit;
        if SetVisiblity(Replacement) then
            CurrPage.Update();
    end;

    local procedure SetVisiblity(var ReplacementHeader: Record DMTReplacement): Boolean
    begin
        CompareValue2_Visible := ReplacementHeader."No. of Compare Values" in [ReplacementHeader."No. of Compare Values"::"2"];
        NewValue2_Visible := ReplacementHeader."No. of Values to modify" in [ReplacementHeader."No. of Values to modify"::"2"];
    end;

    internal procedure UpdatePageParts(ReplacementOld: Record DMTReplacement; Replacement: Record DMTReplacement)
    begin
        CurrPage.Assignments.Page.InitializeAsAssignmentPerReplacement();
        if not Replacement.IsEqual(ReplacementOld) then
            CurrPage.Rules.Page.EnableControls(Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        EnableControls(xRec, Rec);
        UpdatePageParts(xRec, Rec);
    end;

    var
        CompareValue2_Visible, NewValue2_Visible : Boolean;
}