unit uProducao_Etiquetas;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Dialogs;

Type
  TProducaoEtiquetas = class(TInterfacedObject, iEntidade)
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
      procedure SelecionaSQLConsulta;
  end;
implementation
uses
  uEntidadeBase;

{ TProducao }

constructor TProducaoEtiquetas.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
end;

destructor TProducaoEtiquetas.Destroy;
begin
  inherited;
end;

class function TProducaoEtiquetas.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProducaoEtiquetas.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProducaoEtiquetas.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.SetReadOnly(Value, 'nome_prod', False);
  FEntidadeBase.SetReadOnly(Value, 'peso', False);
  FEntidadeBase.SetReadOnly(Value, 'cod_barra', False);
  FEntidadeBase.SetReadOnly(Value, 'preco_vend', False);
  FEntidadeBase.SetReadOnly(Value, 'cnpj_fornec', False);
  FEntidadeBase.SetReadOnly(Value, 'nome_fornec', False);
  FEntidadeBase.SetReadOnly(Value, 'composicao', False);
  FEntidadeBase.SetReadOnly(Value, 'niveis_garantia', False);
end;

function TProducaoEtiquetas.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.AddParametro('pid_producao', -1);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProducaoEtiquetas.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dt_fabricacao')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dt_vencimento')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dt_embalagem')).EditMask:= '!99/99/00;1;_';
end;

function TProducaoEtiquetas.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TProducaoEtiquetas.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL(
    'select pe.*, p.nome_prod, p.peso, p.cod_barra, p.preco_vend, f.cgc as cnpj_fornec, ' +
    'f.nome as nome_fornec, ppe.composicao, ppe.niveis_garantia ' +
    'from producao_etiquetas pe ' +
    'join produtos p on (p.cod_prod = pe.cod_produto) ' +
    'left join produtos_producao_etiquetas ppe on (ppe.cod_prod = p.cod_prod) ' +
    'left join fornec f on (f.codigo = ppe.cod_fornec) ' +
    'where pe.id_producao = :pid_producao ');
end;

end.
