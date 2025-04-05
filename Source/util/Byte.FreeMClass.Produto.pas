unit Byte.FreeMClass.Produto;

interface

uses
  uMulticlass, System.SysUtils, System.Classes;

type
  IFreeMClassProduto = interface
    ['{10479E18-57AF-46DC-95EA-D41C3F47560E}']
    function Token(AValue: String): IFreeMClassProduto;
    function Ref: String;
    function Descricao: String;
    function Unidade: String;
    function Marca: String;
    function NCM: String;
    function Cest: String;
    function ConsultaProduto(ACodBarras: String): Boolean;
  end;

  TFreeMClassProduto = class(TInterfacedObject, IFreeMClassProduto)
    private
      FToken: String;
      FRef, FDescricao, FUnidade, FMarca, FNCM, FCest: String;
      constructor Create;
      destructor Destroy; override;
    public
      class function New: IFreeMClassProduto;
      function Token(AValue: String): IFreeMClassProduto;
      function Ref: String;
      function Descricao: String;
      function Unidade: String;
      function Marca: String;
      function NCM: String;
      function Cest: String;
      function ConsultaProduto(ACodBarras: String): Boolean;
  end;

implementation

{ TFreeMClassProduto }

class function TFreeMClassProduto.New: IFreeMClassProduto;
begin
  Result:= Self.Create;
end;

constructor TFreeMClassProduto.Create;
begin
  FRef:= '';
  FDescricao:= '';
  FUnidade:= '';
  FMarca:= '';
  FNCM:= '';
  FCest:= '';
end;

destructor TFreeMClassProduto.Destroy;
begin

  inherited;
end;

function TFreeMClassProduto.Token(AValue: String): IFreeMClassProduto;
begin
  Result:= Self;
  FToken:= AValue;
end;

function TFreeMClassProduto.ConsultaProduto(ACodBarras: String): Boolean;
var
  vMulticlass : TMulticlass;
begin
  Result:= False;
  try
    if FToken.IsEmpty then
      raise Exception.Create('Token não informado.');
    if ACodBarras.IsEmpty then
      raise Exception.Create('Código de barras não informado.');

    vMulticlass:= TMulticlass.create;
    try
      vMulticlass.TokenConsultaProd:= FToken;
      vMulticlass.ConsultarProduto(ACodBarras);
      Result:= vMulticlass.Produto.Consultou;
      if vMulticlass.Produto.Consultou then begin
        FRef:= vMulticlass.Produto.Produto.ref;
        FDescricao:= vMulticlass.Produto.Produto.descricao;
        FUnidade:= vMulticlass.Produto.Produto.un;
        FMarca:= vMulticlass.Produto.Produto.marca;
        FNCM:= vMulticlass.Produto.Produto.ncm;
        FCest:= vMulticlass.Produto.Produto.cest;
      end;
    finally
      vMulticlass.Free;
    end;
  except
    on E:Exception do begin
      raise Exception.Create('Erro: ' + E.Message);
    end;
  end;
end;

function TFreeMClassProduto.NCM: String;
begin
  Result:= FNCM;
end;

function TFreeMClassProduto.Marca: String;
begin
  Result:= FMarca;
end;

function TFreeMClassProduto.Cest: String;
begin
  Result:= FCest;
end;

function TFreeMClassProduto.Unidade: String;
begin
  Result:= FUnidade;
end;

function TFreeMClassProduto.Ref: String;
begin
  Result:= FRef;
end;

function TFreeMClassProduto.Descricao: String;
begin
  Result:= FDescricao;
end;

end.
