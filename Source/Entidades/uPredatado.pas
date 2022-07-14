unit uPredatado;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TPredatado = class(TInterfacedObject, iEntidade)
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

{ TPredatado }

constructor TPredatado.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From PREDAT Where COD_FILIAL = :pCodFilial ');
  InicializaDataSource;
end;

destructor TPredatado.Destroy;
begin
  inherited;
end;

class function TPredatado.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPredatado.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPredatado.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
  vIndice: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vIndice:= 'Vencimento';
  vTextoSQL:= FEntidadeBase.TextoSql;
  Case FEntidadeBase.TipoPesquisa of
    //busca por Predatados em aberto
    0: begin
      vTextoSQL:= vTextoSQL + ' and BAIXADO = ''X'' ';
      if FEntidadeBase.RegraPesquisa <> '30/12/99 30/12/99' then begin
        If Copy(FEntidadeBase.RegraPesquisa,1,8) = '30/12/99' then
          vTextoSQL:= vTextoSQL + ' and vencimento <= :pDtFim'
        else
          vTextoSQL:= vTextoSQL + ' and vencimento between :pDtInicio and :pDtFim';
      end;
    end;
    //busca por Predatados baixados
    1: begin
      vTextoSQL:= vTextoSQL + ' and BAIXADO <> ''X'' ';
      if FEntidadeBase.RegraPesquisa <> '30/12/99 30/12/99' then begin
        If Copy(FEntidadeBase.RegraPesquisa,1,8) = '30/12/99' then
          vTextoSQL:= vTextoSQL + ' and dt_baixa <= :pDtFim'
        else
          vTextoSQL:= vTextoSQL + ' and dt_baixa between :pDtInicio and :pDtFim';
      end;
      vIndice:= 'Dt_Baixa';
    end;
    //busca por Predatados em aberto mesmo CPF
    2: vTextoSQL:= vTextoSql + ' and BAIXADO <> ''S'' and CPF = :pCpf';
    3: vTextoSQL:= vTextoSQL + ' and BAIXADO = :pBaixado and ' + FEntidadeBase.TextoPesquisa + ' ' + FEntidadeBase.RegraPesquisa + ':' + FEntidadeBase.TextoPesquisa;
  end;
  FEntidadeBase.Iquery.Dataset.FieldDefs.Clear;
  FEntidadeBase.Iquery.Dataset.Fields.Clear;
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  FEntidadeBase.Iquery.IndexFieldNames(vIndice);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPredatado.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From PREDAT Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPredatado.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('valor')).currency:= True;
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dt_venda')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('vencimento')).EditMask:= '!99/99/00;1;_';
end;

function TPredatado.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
