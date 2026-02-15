"use client";

import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { UserForm } from "@/components/settings/user-form";
import { FilterForm } from "@/components/settings/filter-form";
import { NotificationForm } from "@/components/settings/notification-form";

export default function SettingsPage() {
  return (
    <Tabs defaultValue="user" className="space-y-4">
      <TabsList>
        <TabsTrigger value="user">User Data</TabsTrigger>
        <TabsTrigger value="filter">Filter</TabsTrigger>
        <TabsTrigger value="notification">Notifications</TabsTrigger>
      </TabsList>
      <TabsContent value="user">
        <UserForm />
      </TabsContent>
      <TabsContent value="filter">
        <FilterForm />
      </TabsContent>
      <TabsContent value="notification">
        <NotificationForm />
      </TabsContent>
    </Tabs>
  );
}
