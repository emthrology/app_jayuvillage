import 'package:flutter/material.dart';
import 'package:webview_ex/component/organization_manager_status/branch_list_card.dart';

class GeneralManagerChecklist extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final List<dynamic> managerList;
  final Function(int id) onCardTap;

  const GeneralManagerChecklist({super.key, required this.profileData, required this.onCardTap, required this.managerList});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text(
              '${profileData['draft_state_name']} ${profileData['position']}: ${profileData['name']}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
              child: ListView.builder(
            itemCount: managerList.length,
            itemBuilder: (BuildContext ctx, int idx) {
              return GestureDetector(
                  onTap: () => onCardTap(managerList[idx]['id']),
                  child: BranchListCard(listItem: managerList[idx]));
            },
          ))
        ],
      ),
    );
  }
}
