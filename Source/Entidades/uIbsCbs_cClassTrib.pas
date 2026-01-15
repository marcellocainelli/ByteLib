unit uIbsCbs_cClassTrib;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TIbsCbs_cClassTrib = class(TInterfacedObject, iEntidade)
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

{ TIbsCbs_cClassTrib }

constructor TIbsCbs_cClassTrib.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from IBSCBS_CLASSTRIB ');
  InicializaDataSource;
end;

destructor TIbsCbs_cClassTrib.Destroy;
begin
  inherited;
end;

class function TIbsCbs_cClassTrib.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TIbsCbs_cClassTrib.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TIbsCbs_cClassTrib.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  Case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' Where CODIGO = :Parametro';
    2: vTextoSQL:= vTextoSQL + ' Where DESCRICAO CONTAINING :Parametro';
  end;
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  FEntidadeBase.Iquery.IndexFieldNames('CODIGO');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
end;

function TIbsCbs_cClassTrib.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * from IBSCBS_CLASSTRIB Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TIbsCbs_cClassTrib.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('IBSPREDALIQ')).DisplayFormat:= '#,0.00';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('CBSPREDALIQ')).DisplayFormat:= '#,0.00';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('VALIDADE')).EditMask:= '!99/99/00;1;_';
end;

function TIbsCbs_cClassTrib.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
