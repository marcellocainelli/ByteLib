unit uEstoqueFilialGrade;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TEstoqueFilialGrade = class(TInterfacedObject, iEntidade)
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


{ TEstoqueFilialGrade }

constructor TEstoqueFilialGrade.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select efg.*, pt.descricao as tamanho, pc.descricao as cor ' +
    'from estoquefilial_grade efg ' +
    'left join produtos_tamanho pt on (pt.codigo = efg.cod_tamanho) ' +
    'left join produtos_cores pc on (pc.codigo = efg.cod_cor) ' +
    'where cod_filial = :pcod_filial and cod_prod = :pcod_prod ');
end;

destructor TEstoqueFilialGrade.Destroy;
begin
  inherited;
end;

class function TEstoqueFilialGrade.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEstoqueFilialGrade.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEstoqueFilialGrade.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.SetReadOnly(Value, 'TAMANHO', False);
  FEntidadeBase.SetReadOnly(Value, 'COR', False);
end;

function TEstoqueFilialGrade.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('pCod_Filial', '-1', ftString);
  FEntidadeBase.AddParametro('pCod_prod', '-1', ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEstoqueFilialGrade.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.00';
end;

function TEstoqueFilialGrade.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
