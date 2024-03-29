page 73010 DMTFieldLookup
{
    Caption = 'Fields', comment = 'Felder';
    PageType = List;
    UsageCategory = None;
    SourceTable = DMTFieldBuffer;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(fields)
            {
                field("Field Caption"; Rec."Field Caption") { ApplicationArea = All; }
                field(FieldName; Rec.FieldName) { ApplicationArea = All; }
                field(TableNo; Rec.TableNo) { ApplicationArea = All; }
                field("Type Name"; Rec."Type Name") { ApplicationArea = All; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        LoadLines();
    end;

    procedure LoadLines()
    var
        DataFile: Record DMTDataFile;
        TempFieldBuffer: Record DMTFieldBuffer temporary;
        GenBuffTable: Record DMTGenBuffTable;
        Field: Record Field;
        BuffTableCaptions: Dictionary of [Integer, Text];
        FieldNo: Integer;
    begin
        if IsLoaded then exit;
        Rec.FilterGroup(4);
        case true of
            Rec.GetFilter(TableNo) <> '':
                begin
                    DataFile.BufferTableType := DataFile.BufferTableType::"Seperate Buffer Table per CSV";
                    DataFile."Buffer Table ID" := Rec.GetRangeMin(TableNo);
                end;
            Rec.GetFilter("Data File ID Filter") <> '':
                begin
                    DataFile.Get(Rec.GetRangeMin("Data File ID Filter"));
                end;
            else
                Error('unhandled case');
        end;
        if Rec.GetFilter(TableNo) <> '' then begin

        end;
        if Rec.GetFilter("Data File ID Filter") <> '' then begin

        end;
        Rec.FilterGroup(0);


        case DataFile.BufferTableType of
            DataFile.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    GenBuffTable.GetColCaptionForImportedFile(DataFile, BuffTableCaptions);
                    foreach FieldNo in BuffTableCaptions.Keys do begin
                        TempFieldBuffer.TableNo := GenBuffTable.RecordId.TableNo;
                        TempFieldBuffer."No." := FieldNo + 1000;
                        TempFieldBuffer."Field Caption" := CopyStr(BuffTableCaptions.Get(FieldNo), 1, MaxStrLen(TempFieldBuffer."Field Caption"));
                        TempFieldBuffer.Insert();
                    end;
                    IsLoaded := true;
                end;

            DataFile.BufferTableType::"Seperate Buffer Table per CSV":
                begin
                    Field.SetRange(TableNo, DataFile."Buffer Table ID");
                    Field.SetFilter("No.", '<2000000000'); // no system fields
                    Field.FindSet(false, false);
                    repeat
                        TempFieldBuffer.ReadFrom(Field);
                        TempFieldBuffer.Insert(false);
                    until Field.Next() = 0;
                    IsLoaded := true;
                end;
        end;

        Rec.Copy(TempFieldBuffer, true);
    end;

    var
        [InDataSet]
        IsLoaded: Boolean;
}