##########################################################################
#
# pgAdmin 4 - PostgreSQL Tools
#
# Copyright (C) 2013 - 2020, The pgAdmin Development Team
# This software is released under the PostgreSQL Licence
#
##########################################################################

import uuid
import json

from pgadmin.browser.server_groups.servers.databases.schemas.tests import \
    utils as schema_utils
from pgadmin.browser.server_groups.servers.databases.tests import utils as \
    database_utils
from pgadmin.utils.route import BaseTestGenerator
from regression import parent_node_dict
from regression.python_test_utils import test_utils as utils
from . import utils as domain_utils


class DomainDeleteMultipleTestCase(BaseTestGenerator):
    """ This class will delete new domains under schema node. """
    scenarios = [
        # Fetching default URL for domain node.
        ('Fetch domain Node URL', dict(url='/browser/domain/obj/'))
    ]

    def setUp(self):
        super(DomainDeleteMultipleTestCase, self).setUp()
        self.database_info = parent_node_dict["database"][-1]
        self.db_name = self.database_info["db_name"]
        self.schema_info = parent_node_dict["schema"][-1]
        self.schema_name = self.schema_info["schema_name"]
        self.schema_id = self.schema_info["schema_id"]
        self.domain_names = ["domain_delete_%s" % (str(uuid.uuid4())[1:8]),
                             "domain_delete_%s" % (str(uuid.uuid4())[1:8])]
        self.domain_infos = [domain_utils.create_domain(self.server,
                                                        self.db_name,
                                                        self.schema_name,
                                                        self.schema_id,
                                                        self.domain_names[0]),
                             domain_utils.create_domain(self.server,
                                                        self.db_name,
                                                        self.schema_name,
                                                        self.schema_id,
                                                        self.domain_names[1])]

    def runTest(self):
        """ This function will add domain under schema node. """
        db_id = self.database_info["db_id"]
        server_id = self.database_info["server_id"]
        db_con = database_utils.connect_database(self, utils.SERVER_GROUP,
                                                 server_id, db_id)
        if not db_con['data']["connected"]:
            raise Exception("Could not connect to database to get the domain.")
        db_name = self.database_info["db_name"]
        schema_response = schema_utils.verify_schemas(self.server,
                                                      db_name,
                                                      self.schema_name)
        if not schema_response:
            raise Exception("Could not find the schema to get the domain.")
        data = {'ids': [self.domain_infos[0][0], self.domain_infos[1][0]]}
        url = self.url + str(utils.SERVER_GROUP) + '/' + str(
            server_id) + '/' + str(db_id) + '/' + str(self.schema_id) + "/"
        # Call GET API to verify the domain
        get_response = self.tester.delete(
            url,
            content_type='html/json',
            follow_redirects=True,
            data=json.dumps(data))

        self.assertEquals(get_response.status_code, 200)
        # Disconnect the database
        database_utils.disconnect_database(self, server_id, db_id)

    def tearDown(self):
        pass
