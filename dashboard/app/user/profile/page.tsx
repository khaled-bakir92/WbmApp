"use client";

import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { UserForm } from "@/components/settings/user-form";
import { FilterForm } from "@/components/settings/filter-form";

export default function UserProfilePage() {
  return (
    <Tabs defaultValue="user" className="space-y-4">
      <TabsList>
        <TabsTrigger value="user">User Data</TabsTrigger>
        <TabsTrigger value="filter">Filter</TabsTrigger>
      </TabsList>
      <TabsContent value="user">
        <UserForm readOnly />
      </TabsContent>
      <TabsContent value="filter">
        <FilterForm />
      </TabsContent>
    </Tabs>
  );
}
