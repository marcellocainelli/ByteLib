unit uCadbanCobranca;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TCadbanCobranca = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;

      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TCadbanCobranca }

constructor TCadbanCobranca.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CADBAN_COBRANCA where COD_FILIAL = :pCod_Filial');
end;

destructor TCadbanCobranca.Destroy;
begin
  inherited;
end;

class function TCadbanCobranca.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TCadbanCobranca.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TCadbanCobranca.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  //FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TCadbanCobranca.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  //FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TCadbanCobranca.ModificaDisplayCampos;
begin

end;

end.
