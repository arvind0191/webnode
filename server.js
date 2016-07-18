try {
    var express = require('express');
    var jwt = require("jsonwebtoken");
    var jwtCheck = require("express-jwt");
    var pg = require("pg");
    var http = require("http");
    var port = 5433;
    var app = express();
    var bodyParser = require('body-parser');
    pg.defaults.password = 'root';
    app.use(bodyParser());
    var conString = "pg://postgres:root@localhost:5432/mdmdb";
    var client = new pg.Client(conString);
    var Promise = require("bluebird");
    var GCM = require('gcm').GCM;
    var gcm = new GCM('AIzaSyAA8QSZC7qI-2BbkSzKwSSBHp9ZbS2KdsU');
    var uuid = require('node-uuid');
    var bcrypt = require('bcrypt');
    var nodemailer = require('nodemailer');
    var smtpTransport = require('nodemailer-smtp-transport');

    client.connect();

    //Post method  for user authentication ---------------------------------------//
    app.post('/api/provisioning', function (req, res) {
        if (req.body.deviceId != null && req.body.deviceId != '') {
            console.log(req.body);
            var query = client.query("select * from provisioning_table where sn = (select provisionig_id from device_master where imei = '" + req.body.deviceId + "')"); //stored procedure  - getuser(loginid) return entire row //
            console.log("select * from provisioning_table where sn = (select provisionig_id from device_master where imei = '" + req.body.deviceId + "')");
            query.on("row", function (row, result) {
                result.addRow(row);
            });
            query.on("end", function (result) {
                if (result.rows.length < 1) {

                    res.send({
                        "error": true,
                        "response": "unable to get record for deviceId - " + req.body.deviceId + " error -" + result.rows
                    });
                } else {
                    var apiToken = jwt.sign({
                        user: req.body.loginId,
                        app: req.body.app,
                        scopes: ['sendnotification', '/device/authentication', 'teachers', 'performance', 'testreports', 'testdetail', 'user']
                    }, 'API_SECRET');
                    result.rows[0]['token'] = apiToken;
                    res.send({'error': false, 'token': apiToken, 'response': result.rows[0]}).status(201);
                }
            });
        } else {
            res.send({"error": true, "response": "unable to get the proper imei/mac"}).status(404);
        }

    });
    // app.use('/api', jwtCheck({
    //     secret: 'API_SECRET',
    //     userProperty: "token"
    // }));
    // app.use(function (err, req, res, next) {
    //     if (err.name === 'UnauthorizedError') {
    //         res.status(401).send('Unauthorized user ...');
    //     }
    // });


    app.post('/api/sendnotification', function (req, res) { //destinationId  = loginid /groupid
        if (req.body.type != null && req.body.destinationId != null && req.body.title != null && req.body.message != null && req.body.type != '' && req.body.destinationId != '' && req.body.title != '' && req.body.message != '') {

            var query = client.query("SELECT addmessage('" + req.body.message + "','" + req.body.destinationId + "'," + req.body.type + "')", function (err, result) {
                if (err) {
                    console.log("error" + err);
                } else {

                    var promises;
                    switch (req.body.type) {
                        case 1:
                            var ids = [];
                            promises = (new Promise(function (fulfill, reject) {
                                client.query("select * from getdestination('" + req.body.destinationId + "')", function (err, result) {
                                    if (err) {
                                        res.send({"error": true, "response": "" + err});
                                    } else {
                                        if (result.rows.length > 0) {
                                            console.log("message - " + JSON.stringify(result.row));
                                            ids.push(result.rows[0]['getdestination']);
                                            fulfill(ids[0]);
                                        } else {
                                            res.send({"error": true, "response": "No data found for the selections"});
                                        }
                                    }
                                });
                            }))
                            break;
                        case 2:
                            var ids = [];
                            promises = (new Promise(function (fulfill, reject) {
                                client.query("select * from getgroupaddress('" + req.body.destinationId + "')", function (err, result) {
                                    if (err) {
                                        res.send({"error": true, "response": "" + err});
                                    } else {
                                        if (result.rows.length > 0) {
                                            console.log("message - " + JSON.stringify(result.rows));
                                            var i = 0;
                                            for (i = 0; i < result.rows.length; i++) {
                                                ids.push(result.rows[i]['devicetoken']);
                                            }
                                            fulfill(ids);


                                        } else {
                                            res.send({"error": true, "response": "No data found for the selections"});
                                        }

                                    }
                                });
                            }))


                            break;
                    }

                    Promise.join(promises, function (array) {
                        console.log('array', array);
                        var notificationMsg = {
                            registration_id: array, // required
                            collapse_key: 'Collapse key',
                            'data.title': req.body.title,
                            'data.message': req.body.message
                        };

                        console.log('notification text', JSON.stringify(notificationMsg));
                        gcm.send(notificationMsg, function (err, result3) {
                            console.log('in function');
                            if (err) {
                                res.send({"error": true, "response": "error sending notification !! " + err});
                            } else {
                                res.send({
                                    "error": false,
                                    "response": "notification sent successfully with notification id " + notificationId
                                });
                            }
                        });
                    });


                }

            });
        } else {
            res.send({"error": true, "response": "please enter valid params"}).status(404);
        }
    });
    app.post('/api/device/authentication', function (req, res) {
        if (req.body.loginId != null && req.body.loginId != '' && req.body.password != null && req.body.password != '') {
            var query = client.query("select * from user_table where loginId = ('" + req.body.loginId + "')");
            query.on("row", function (row, result) {
                result.addRow(row);
            });
            query.on("end", function (result) {
                if (result.rows.length < 1) {
                    res.send({'error': true, 'response': "No record found for the user - " + req.body.loginId});
                } else {
                    if (result.rows[0].password === req.body.password) {
                        res.send({'error': false, 'response': result.rows});

                    } else {
                        res.send({"error": true, "response": "please enter valid username/password"}).status(403);
                    }
                }
            });
        } else {
            res.send({"error": true, "response": "please enter valid params"}).status(404);
        }
    });

    app.post('/api/company/authentication', function (req, res) {
        if (req.body.loginId != null && req.body.loginId != '' && req.body.password != null && req.body.password != '' && req.body.company != null && req.body.company != '') {
            var query = client.query("select * from company_table where login_id = '" + req.body.loginId + "'");
            query.on("row", function (row, result) {
                result.addRow(row);
            });
            query.on("end", function (result) {
                if (result.rows.length < 1) {
                    res.send({'error': true, 'response': "No record found for the user - " + req.body.loginId});
                } else {
                    if (result.rows[0].password === req.body.password) {

                        client.query("select * from getdevicelist('" + result.rows[0].compnay_id + "')", function (err, data) {
                            if (err) {
                                res.send({
                                    'error': true,
                                    'response': "No record found for the user - " + req.body.loginId
                                });

                            } else {
                                if (data.rows.length < 1) {

                                } else {
                                    res.send({'error': false, 'response': data.rows});

                                }

                            }
                        });


                    } else {
                        res.send({"error": true, "response": "please enter valid username/password"}).status(403);
                    }
                }
            });
        } else {
            res.send({"error": true, "response": "please enter valid params"}).status(500);
        }
    });
    app.post('/api/user/registration', function (req, res) {
        if (req.body.loginId != null && req.body.loginId != '' && req.body.password != null && req.body.password != '' && req.body.company != null && req.body.company != '') {
            var query = client.query("select addcompany('" + req.body.companyName + "','" + req.body.companyId + "','" + req.body.loginId + "','" + req.body.password + "')", function (err, result) {
                if (err) {
                    res.send({"error": true, "response": "please enter valid params"}).status(500);

                }
            });

        } else {
            res.send({"error": true, "response": "please enter valid params"}).status(500);
        }
    });

    app.post('/api/company/registration', function (req, res) {
        if (req.body.loginId != null && req.body.loginId != '' && req.body.password != null && req.body.password != '' && req.body.company != null && req.body.company != '') {
            var query = client.query("select addcompany('" + req.body.companyName + "','" + req.body.companyId + "','" + req.body.loginId + "','" + req.body.password + "')", function (err, result) {
                if (err) {
                    res.send({"error": true, "response": "please enter valid params"}).status(500);

                } else {
                    res.send({"error": false, "response": "success"})
                }
            });

        } else {
            res.send({"error": true, "response": "please enter valid params"}).status(500);
        }
    });


    app.post('/api/device/registration', function (req, res) {
        if (req.body.companyId != null && req.body.companyId != '' && req.body.password != null && req.body.password != '' && req.body.imei != null && req.body.userId != '') {
            var query = client.query("select adddevice('" + req.body.companyId + "','" + req.body.imei + "','" + req.body.mac + "','" + req.body.userId + "','" + req.body.password + "')", function (err, result) {
                if (err) {
                    res.send({"error": true, "response": "please enter valid params"}).status(500);

                } else {
                    res.send({"error": false, "response": "success"})
                }
            });

        } else {
            res.send({"error": true, "response": "please enter valid params"}).status(500);
        }
    });

    // get the device detils with input imei address
    app.post('/api/getdevicedetails', function (req, res) {
        if (req.body.imei != null && req.body.imei != '') {
            var query = client.query("select * from getdevicedetail('" + req.body.imei + "')", function (err, result) {
                if (err) {
                    res.send({"error": true, "response": "please enter valid params"}).status(500);
                } else {
                    res.send({'error': false, 'response': result.rows});

                }
            });
        }

    });

    app.post('/api/getwhitelist', function (req, res) {
        if (req.body.userid != null && req.body.userid != '') {
            var query = client.query("select * from getwhitelist('" + req.body.userid + "')", function (err, result) {
                if (err) {
                    res.send({"error": true, "response": "please enter valid params"}).status(500);

                } else {
                    res.send({'error': false, 'response': result.rows});

                }
            });


        } else {
            res.send({"error": true, "response": "please enter valid params"}).status(500);

        }
    });
    app.post('/api/getblacklist', function (req, res) {
        if (req.body.userid != null && req.body.userid != '') {
            var query = client.query("select * from getblacklist('" + req.body.userid + "')", function (err, result) {
                if (err) {
                    res.send({"error": true, "response": "please enter valid params"}).status(500);

                } else {
                    res.send({'error': false, 'response': result.rows});

                }
            });


        } else {
            res.send({"error": true, "response": "please enter valid params"}).status(500);

        }
    });
    app.post('/api/getapplist', function (req, res) {
        if (req.body.userid != null && req.body.userid != '') {
            var query = client.query("select * from getinstalledapp('" + req.body.userid + "')", function (err, result) {
                if (err) {
                    res.send({"error": true, "response": "please enter valid params"}).status(500);

                } else {
                    res.send({'error': false, 'response': result.rows});

                }
            });


        } else {
            res.send({"error": true, "response": "please enter valid params"}).status(500);

        }
    });
    app.post('/api/completeapplist', function (req, res) {
        if (req.body.userid != null && req.body.userid != '') {
            var query = client.query("select * from getapplist('" + req.body.userid + "')", function (err, result) {
                if (err) {
                    res.send({"error": true, "response": "please enter valid params"}).status(500);

                } else {
                    res.send({'error': false, 'response': result.rows});

                }
            });


        } else {
            res.send({"error": true, "response": "please enter valid params"}).status(500);

        }
    });


    function executeQuery(query1) {
        return new Promise(function (fulfill, reject) {
            var query = client.query(query1);
            query.on("row", function (row, result) {
                result.addRow(row);
            });
            return query.on("end", function (result1) {
                fulfill(result1);
            });
        });

    }

    app.listen(3000);
    console.log('Listening on port 3000...');
} catch (err) {
    console.log(err);
}

