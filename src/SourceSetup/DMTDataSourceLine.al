table 91009 "DMTDataSourceLine"
{
    Caption = 'DMT Data Source Line';
    fields
    {
        field(1; "Data Source Code"; Code[100]) { CaptionML = ENU = 'Data Source No.', DEU = 'Datenquelle Nr.'; TableRelation = DMTDataSourceHeader; }
        field(2; "Line No."; Integer) { CaptionML = ENU = 'Line No.', DEU = 'Zeilennr.'; }
        field(10; "Column Name"; Text[250]) { CaptionML = ENU = 'Column Name', DEU = 'Spaltenname'; }
    }
    keys
    {
        key(PK; "Data Source Code", "Line No.") { Clustered = true; }
    }

    procedure FilterFor(DataSourceHeader: Record DMTDataSourceHeader) HasLines: Boolean
    begin
        Rec.SetRange("Data Source Code", DataSourceHeader.Code);
        HasLines := not Rec.IsEmpty;
    end;
}