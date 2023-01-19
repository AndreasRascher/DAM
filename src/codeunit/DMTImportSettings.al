codeunit 110015 "DMTImportSettings"
{
    procedure SourceTableView(SourceTableViewNEW: Text)
    begin
        SourceTableViewGlobal := SourceTableViewNEW;
    end;

    procedure SourceTableView() SourceTableView: Text
    begin
        exit(SourceTableViewGlobal);
    end;

    procedure SetFieldMapping(var TempFieldMapping: Record DMTFieldMapping temporary)
    begin
        TempFieldMappingGlobal.Copy(TempFieldMapping, true);
    end;

    procedure GetFieldMapping(var TempFieldMapping: Record DMTFieldMapping temporary)
    begin
        if TempFieldMappingGlobal.IsEmpty then
            Error('FieldMapping empty');
        TempFieldMapping.Copy(TempFieldMappingGlobal, true);
    end;

    procedure NoUserInteraction(NoUserInteractionNew: Boolean)
    begin
        NoUserInteractionGlobal := NoUserInteractionNew;
    end;

    procedure NoUserInteraction() NoUserInteraction: Boolean
    begin
        exit(NoUserInteractionGlobal);
    end;

    procedure DataFile(var DataFileNew: Record DMTDataFile)
    begin
        DataFileGlobal.Copy(DataFileNew);
    end;

    procedure DataFile() DataFile: Record DMTDataFile
    begin
        DataFile.CalcFields("Target Table Caption");
        exit(DataFileGlobal);
    end;

    procedure ProcessingPlan(var ProcessingPlanNew: Record DMTProcessingPlan)
    begin
        ProcessingPlanGlobal.Copy(ProcessingPlanNew);
    end;

    procedure ProcessingPlan() ProcessingPlan: Record DMTProcessingPlan
    begin
        exit(ProcessingPlanGlobal);
    end;

    procedure UpdateFieldsFilter(UpdateFieldsFilterNew: Text)
    begin
        UpdateFieldsFilterGlobal := UpdateFieldsFilterNew;
    end;

    procedure UpdateFieldsFilter() UpdateFieldsFilter: Text
    begin
        exit(UpdateFieldsFilterGlobal);
    end;

    procedure RecIdToProcessList(var RecIdToProcessList: List of [RecordId])
    begin
        RecIdToProcessListGlobal := RecIdToProcessList;
    end;

    procedure RecIdToProcessList(): List of [RecordId]
    begin
        exit(RecIdToProcessListGlobal);
    end;

    procedure UpdateExistingRecordsOnly(UpdateExistingRecordsOnlyNew: Boolean)
    begin
        UpdateExistingRecordsOnlyGlobal := UpdateExistingRecordsOnlyNew;
    end;

    procedure UpdateExistingRecordsOnly(): Boolean
    begin
        exit(UpdateExistingRecordsOnlyGlobal);
    end;

    var
        SourceTableViewGlobal, UpdateFieldsFilterGlobal : Text;
        NoUserInteractionGlobal, UpdateExistingRecordsOnlyGlobal : Boolean;
        TempFieldMappingGlobal: Record DMTFieldMapping temporary;
        DataFileGlobal: Record DMTDataFile;
        ProcessingPlanGlobal: Record DMTProcessingPlan;
        RecIdToProcessListGlobal: List of [RecordId];
}