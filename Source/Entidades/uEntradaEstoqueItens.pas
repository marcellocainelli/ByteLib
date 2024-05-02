unit uEntradaEstoqueItens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils;
Type
  TEntradaEstoqueItens = class(TInterfacedObject, iEntidade)
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

{ TEntradaEstoqueItens }

constructor TEntradaEstoqueItens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select E.*, P.NOME_PROD, P.COD_BARRA From ESTOQUE E Join PRODUTOS P On (P.COD_PROD = E.COD_PROD) ');
  InicializaDataSource;
end;

destructor TEntradaEstoqueItens.Destroy;
begin
  inherited;
end;

class function TEntradaEstoqueItens.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEntradaEstoqueItens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEntradaEstoqueItens.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where e.seq_mestre = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('seq');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, 'Marcado', ftBoolean);
  FEntidadeBase.SetReadOnly(Value, 'NOME_PROD', False);
  FEntidadeBase.SetReadOnly(Value, 'COD_BARRA', False);
  ModificaDisplayCampos;
  Value.DataSet.Open;
end;

function TEntradaEstoqueItens.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('seq');
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where e.seq_mestre = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEntradaEstoqueItens.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANT_ENT')).DisplayFormat:= '#,0.00';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QTDD_CONFERENCIA')).DisplayFormat:= '#,0.00';
end;

function TEntradaEstoqueItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
