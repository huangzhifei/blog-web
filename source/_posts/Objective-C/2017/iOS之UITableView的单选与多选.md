---
title: iOS之UITableView的单选与多选

date: 2017-04-15 14:37:42

tags: iOS

categories: iOS技术

---

#### 1、非编辑模式

```
self.tableView.allowsSelection = YES; // default 单选
//或
self.tableView.allowsSelectionDuringEditing = YES; // 多选
```

#### 2、编辑模式

```
self.tableView.allowsSelectionDuringEditing = YES; // 编辑模式下单选
//或
self.tableView.allowsMultipleSelectionDuringEditing = YES; //  编辑模式下多选
```

但是坑点在：如果你设置了这个 cell 的选择样式为 none

```
[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
```
你就始终无法选择上那行 cell
