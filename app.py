from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from pyramid.response import Response
import psycopg2 as psdb
import json

def execute_statement(stmt):
    #create connection
    conn = psdb.connect(dbname='webshopdb', user='postgres', host='localhost', password='nopasswordforyou')
    cur = conn.cursor()

    cur.execute(stmt)
    rows=cur.fetchall()[0]
    conn.close()
    return rows


def get_products(request):
    """Retrieve list of all products in DB for catalogue representation, -> returns id, name and price"""

    #get products from db
    rows = execute_statement("""SELECT array_to_json(array_agg(pr)) FROM (SELECT id, name, price FROM webshop.product) pr""")[0]    

    #create responseobject
    resp = {}
    resp['products'] = rows
    respjson = json.dumps(resp)
    return json.loads(respjson)

def get_product_details(request):
    """Retrieve all information for a certain product, -> returns id, name, description and price"""

    #get product information from db
    row = execute_statement("""SELECT array_to_json(array_agg(pr)) FROM (SELECT id, name, description, price FROM webshop.product WHERE webshop.product.id = %(product_id)s) pr""" % request.matchdict)[0]

    #create responseobject
    resp = {}
    resp['product'] = row[0]
    respjson = json.dumps(resp)
    return json.loads(respjson)



if __name__ == '__main__':
    with Configurator() as config:

        #get_products
        config.add_route('getproducts', '/getproducts')
        config.add_view(get_products, route_name='getproducts', renderer='json')

        #get_product_details
        config.add_route('getproductdetail', '/getproductdetail/{product_id}')
        config.add_view(get_product_details, route_name='getproductdetail', renderer='json')

        app = config.make_wsgi_app()

    server = make_server('0.0.0.0', 8080, app)
    server.serve_forever()