unit uOrdEquipamentoLocacao;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TOrdEquipamentoLocacao = class(TInterfacedObject, iEntidade)
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

{ TOrdEquipamentoLocacao }

constructor TOrdEquipamentoLocacao.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select oel.*, oe.descricao From ORD_EQUIPAMENTOS_LOCACAO oel join ord_equipamentos oe on (oe.codigo = oel.cod_equipamento) Where (1 = 1) ');
  InicializaDataSource;
end;

destructor TOrdEquipamentoLocacao.Destroy;
begin
  inherited;
end;

class function TOrdEquipamentoLocacao.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOrdEquipamentoLocacao.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrdEquipamentoLocacao.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' and COD_CLI = :mParametro';
    1: vTextoSQL:= FEntidadeBase.TextoSQL + ' and DT_FINAL <= :mParametro';
  end;
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOrdEquipamentoLocacao.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL('Select * From ORD_EQUIPAMENTOS_LOCACAO Where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TOrdEquipamentoLocacao.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dt_inicio')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dt_final')).EditMask:= '!99/99/00;1;_';
end;

function TOrdEquipamentoLocacao.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
