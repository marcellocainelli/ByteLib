unit uConvenio_Descontos;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TConvenio_Descontos = class(TInterfacedObject, iEntidade)
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

{ TConvenio_Descontos }

constructor TConvenio_Descontos.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select CD.*, M.DESCRICAO ' +
    'from CONVENIO_DESCONTOS CD ' +
    'join MARCAS M on (M.CODIGO = CD.COD_GRUPO) ' +
    'where CD.COD_CONVENIO= :pCod_Convenio');

  InicializaDataSource;
end;

destructor TConvenio_Descontos.Destroy;
begin

  inherited;
end;

class function TConvenio_Descontos.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TConvenio_Descontos.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TConvenio_Descontos.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TConvenio_Descontos.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TConvenio_Descontos.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('TX_DESCONTO')).DisplayFormat:= '#,0.00';
end;

function TConvenio_Descontos.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
