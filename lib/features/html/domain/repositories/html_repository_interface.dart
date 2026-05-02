import 'package:handy_allinone/interfaces/repository_interface.dart';
import 'package:handy_allinone/util/html_type.dart';

abstract class HtmlRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getHtmlText(HtmlType htmlType);
}