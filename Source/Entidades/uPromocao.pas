unit uPromocao;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;
Type
  TPromocao = class(TInterfacedObject, iEntidade)
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

{ TPromocao }

constructor TPromocao.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from PROMOCAO where 1 = 1 ');
  InicializaDataSource;
end;

destructor TPromocao.Destroy;
begin
  inherited;
end;

class function TPromocao.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPromocao.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPromocao.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  if not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and STATUS = ''A'' ';
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPromocao.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From PROMOCAO Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPromocao.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('valor_minimo_compra')).currency:= True;
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('data_sorteio')).EditMask:= '!99/99/00;1;_';
end;

function TPromocao.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
