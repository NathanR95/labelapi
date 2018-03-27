from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from pyramid.response import Response
import psycopg2 as psdb
import json

def retrieve(stmt):
    #create connection
    conn = psdb.connect(dbname='webshopdb', user='postgres', host='localhost', password='nopass')
    cur = conn.cursor()
    cur.execute(stmt)
    rows=cur.fetchall()
    conn.close()

    if rows[0][0] == None:
        raise psdb.ProgrammingError('No results for given id')
    #TODO create and return api response codes
    return rows

def create(stmt):
    #create connection
    conn = psdb.connect(dbname='webshopdb', user='postgres', host='localhost', password='nopass')
    cur = conn.cursor()
    cur.execute(stmt)
    conn.commit()
    rows=cur.fetchall()    
    
    #TODO fix spaghetti that I tried to avoid by using this in the first place 
    if rows[0][0] == None:
        conn.rollback()
        raise psdb.ProgrammingError('Something went wrong')
    #TODO create and return api response codes
    conn.close()
    return rows

def products_get(request):
    """Retrieve list of all products in DB for catalogue representation, -> returns id, name and price"""
    
    #initiate response
    faultstring = None
    resp_code = 200

    #get products from db
    try:
        rows = retrieve("""SELECT array_to_json(array_agg(pr)) FROM (SELECT id, name, price FROM webshop.product) pr""")[0][0]
        #TODO create ability to specify amount of items per page and which page
    except Exception as e:
        faultstring = str(e)
        resp_code = 500

    #create responseobject
    resp = {}
    if faultstring:
        resp['faultstring'] = faultstring
    else:
        resp['products'] = rows

    respjson = json.dumps(resp)
    return Response(json_body=json.loads(respjson), status=resp_code)

def product_details_get(request):
    """Retrieve all information for a certain product, -> returns id, name, description and price"""
    
    #initiate response
    faultstring = None
    resp_code = 200

    #get product information from db
    try:
        row = retrieve("""SELECT array_to_json(array_agg(pr)) FROM (SELECT id, name, description, price FROM webshop.product WHERE webshop.product.id = %(product_id)s) pr""" % request.matchdict)[0][0][0]
    except Exception as e:
        faultstring = str(e)
        resp_code = 404

    #create responseobject
    resp = {}
    if faultstring:
        resp['faultstring'] = faultstring
    else:
        resp['product'] = row

    respjson = json.dumps(resp)
    return Response(json_body=json.loads(respjson), status=resp_code)

def shoppingcart_create(request):
    """Create new shoppingcart, -> returns shoppingcart id"""
    
    #initiate response
    faultstring = None
    resp_code = 201
    
    #create new cart
    try:
        new_cart_id = create("""INSERT INTO webshop.shoppingcart DEFAULT VALUES RETURNING id""")[0][0]
    except Exception as e:
        faultstring = str(e)
        resp_code = 500

    #create responseobject
    resp = {}
    if faultstring:
        resp['faultstring'] = faultstring
    else:
        resp['shoppingcart'] = {"id": new_cart_id}

    respjson = json.dumps(resp)
    return Response(json_body=json.loads(respjson), status=resp_code)

def shoppingcart_add_item(request):
    """Add product to shopping cart, input shoppingcart id, product id, and quantity (default=1) -> returns shoppingcart id + contents"""

    #initiate response
    faultstring = None
    resp_code = 201
    
    #get req body content
    body = request.json_body
    product_id = body['product_id']
    shoppingcart_id = body['shoppingcart_id']
    quantity = body['quantity']

    #create new cart
    try:
        new_cart = create("""INSERT INTO webshop.shoppingcart_product (product_id, shoppingcart_id, quantity) VALUES ( %s, %s, %s) RETURNING (SELECT array_to_json(array_agg(prl)) FROM (SELECT product_id, quantity FROM webshop.shoppingcart_product WHERE shoppingcart_id = %s) prl)""" % (product_id, shoppingcart_id, quantity, shoppingcart_id))[0][0]
        #TODO fix bug where apiresponse only shows db state before the commit
    except Exception as e:
        faultstring = str(e)
        resp_code = 500

    #create responseobject
    resp = {}
    if faultstring:
        resp['faultstring'] = faultstring
    else:
        resp['shoppingcart'] = {"id": shoppingcart_id}
        resp['products'] = new_cart

    respjson = json.dumps(resp)
    return Response(json_body=json.loads(respjson), status=resp_code)

#TODO edit cart
#### POST shoppingcart id, product id, new amount

#TODO create order
#### POST shoppingcart id, recipient data, preferred arrival date/time

if __name__ == '__main__':
    with Configurator() as config:

        #products_get
        config.add_route('getproducts', '/products/get')
        config.add_view(products_get, route_name='getproducts', renderer='json', request_method='GET')

        #product_details_get
        config.add_route('getproductdetail', '/productdetail/get/{product_id}')
        config.add_view(product_details_get, route_name='getproductdetail', renderer='json', request_method='GET')

        #shoppingcart_create
        config.add_route('createshoppingcart', '/shoppingcart/create')
        config.add_view(shoppingcart_create, route_name='createshoppingcart', renderer='json', request_method='POST')

        #shoppingcart_add_item
        config.add_route('additemshoppingcart', '/shoppingcart/additem')
        config.add_view(shoppingcart_add_item, route_name='additemshoppingcart', renderer='json', request_method='POST')

        #shoppingcart_edit_item
        #order_create

        app = config.make_wsgi_app()

    server = make_server('0.0.0.0', 8080, app)
    server.serve_forever()