unit uAgenda_Grupos;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TAgenda_Grupos = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;
implementation

uses
  uEntidadeBase;

{ TAgenda_Grupos }

constructor TAgenda_Grupos.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from AGENDA_GRUPOS');

  InicializaDataSource;
end;

destructor TAgenda_Grupos.Destroy;
begin
  inherited;
end;

class function TAgenda_Grupos.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TAgenda_Grupos.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TAgenda_Grupos.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TAgenda_Grupos.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From AGENDA_GRUPOS Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TAgenda_Grupos.ModificaDisplayCampos;
begin

end;

function TAgenda_Grupos.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
