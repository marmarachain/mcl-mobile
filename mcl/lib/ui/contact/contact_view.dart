import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcl/core/init/lang/locale_keys.g.dart';
import 'package:mcl/models/person.dart';
import 'package:mcl/models/chain.dart';
import 'package:mcl/ui/contact/new_person.dart';
import 'package:mcl/widgets/common_page.dart';
import 'package:mcl_ui/mcl_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';

import 'contact_viewmodel.dart';

class ContactView extends StatelessWidget {
  const ContactView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Person? bosPerson = Person(isim: '', cuzdanAdresi: '', pubKey: '');
    return ViewModelBuilder<ContactViewModel>.reactive(
      builder: (context, model, _) => CommonPage(
        backButton: model.backPop,
        localeKeys: LocaleKeys.contact_name,
        appBarWidget: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) {
                  return GestureDetector(
                    onTap: () {},
                    child: NewPerson(model.addNewPerson, bosPerson, -1),
                    behavior: HitTestBehavior.opaque,
                  );
                },
              );
              ;
              //   Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => KisilerView(),
              //   ),
              // )
            },
          )
        ],
        child: ValueListenableBuilder<Box<dynamic>>(
            valueListenable: Hive.box('kisiler').listenable(),
            builder: (context, kisilerBox, widget) {
              return Container(
                // height: screenHeightPercentage(context, percentage: 0.8),
                child: kisilerBox.isEmpty
                    ? Center(
                        child: Text(
                          '${LocaleKeys.contact_yet.tr()}',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemBuilder: (ctx, index) {
                          final kisi = kisilerBox.getAt(index) as Person;
                          return Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: Card(
                              elevation: 5,
                              margin: EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 5,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  child: Padding(
                                    padding: EdgeInsets.all(6),
                                    child: FittedBox(
                                      child: Text(
                                          '${kisi.isim.split(' ')[0].substring(0, 1)}${kisi.isim.split(' ')[kisi.isim.split(' ').length - 1].substring(0, 1)}'),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  kisi.isim,
                                  // style: Theme.of(context).textTheme.title,
                                ),
                                subtitle: Text(
                                  kisi.pubKey,
                                ),
                                // trailing: IconButton(
                                //   icon: Icon(Icons.arrow_right),
                                //   color: Theme.of(context).errorColor,
                                //   onPressed: () => Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => MclDetailView(),
                                //     ),
                                //   ),
                                // ),
                              ),
                            ),
                            actions: <Widget>[
                              IconSlideAction(
                                caption: '${LocaleKeys.contact_address.tr()}',
                                color: Colors.blue,
                                icon: Icons.email_outlined,
                                onTap: () => model.panoyaKopyalandi(
                                    ctx,
                                    kisi.cuzdanAdresi,
                                    '${LocaleKeys.chain_walletAddress.tr()}'),
                              ),
                              IconSlideAction(
                                caption: 'Pubkey',
                                color: Colors.indigo,
                                icon: Icons.share,
                                onTap: () => model.panoyaKopyalandi(
                                    ctx,
                                    kisi.pubKey,
                                    '${LocaleKeys.chain_pubKey.tr()}'),
                              ),
                            ],
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: '${LocaleKeys.common_edit.tr()}',
                                color: Colors.orange,
                                icon: Icons.edit,
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (_) {
                                      return GestureDetector(
                                        onTap: () {},
                                        child: NewPerson(
                                            model.addNewPerson, kisi, index),
                                        behavior: HitTestBehavior.opaque,
                                      );
                                    },
                                  );
                                },
                              ),
                              IconSlideAction(
                                caption: '${LocaleKeys.common_delete.tr()}',
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () => model.deletePerson(index),
                              ),
                            ],
                          );
                        },
                        itemCount: kisilerBox.length,
                      ),
              );
            }),
      ),
      viewModelBuilder: () => ContactViewModel(),
    );
  }
}
