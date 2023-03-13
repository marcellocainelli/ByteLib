unit uConvenio;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TConvenio = class(TInterfacedObject, iEntidade)
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

{ TConvenio }

constructor TConvenio.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select C.codigo, C.nome, C.limite, 0 as INDICE from Convenio C');

  InicializaDataSource;
end;

destructor TConvenio.Destroy;
begin
  inherited;
end;

class function TConvenio.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TConvenio.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TConvenio.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TConvenio.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where 1 <> 1');
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TConvenio.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('LIMITE')).DisplayFormat:= '#,0.00';
end;

function TConvenio.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
