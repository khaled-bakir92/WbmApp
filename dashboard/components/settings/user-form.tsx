"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Loader2 } from "lucide-react";
import { useUserConfig } from "@/hooks/use-user-config";
import type { UserData } from "@/lib/types";

const userSchema = z.object({
  anrede: z.string().min(1, "Required"),
  name: z.string().min(1, "Required"),
  vorname: z.string().min(1, "Required"),
  strasse: z.string().min(1, "Required"),
  plz: z.string().regex(/^\d{5}$/, "Must be 5 digits"),
  ort: z.string().min(1, "Required"),
  email: z.string().email("Invalid email"),
  telefon: z.string().min(1, "Required"),
});

type UserFormValues = z.infer<typeof userSchema>;

function UserFormInner({
  defaultValues,
  onSave,
  isPending,
  readOnly = false,
}: {
  defaultValues: UserData;
  onSave: (values: UserFormValues) => void;
  isPending: boolean;
  readOnly?: boolean;
}) {
  const form = useForm<UserFormValues>({
    resolver: zodResolver(userSchema),
    defaultValues,
  });

  const anrede = form.watch("anrede");

  return (
    <form onSubmit={form.handleSubmit(onSave)} className="space-y-4">
      <div className="grid gap-4 sm:grid-cols-2">
        <div className="space-y-2">
          <Label>Anrede</Label>
          <Select
            value={anrede}
            onValueChange={(v) => form.setValue("anrede", v, { shouldDirty: true })}
            disabled={readOnly}
          >
            <SelectTrigger>
              <SelectValue placeholder="Select..." />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="Herr">Herr</SelectItem>
              <SelectItem value="Frau">Frau</SelectItem>
            </SelectContent>
          </Select>
          {form.formState.errors.anrede && (
            <p className="text-xs text-destructive">
              {form.formState.errors.anrede.message}
            </p>
          )}
        </div>

        <div className="space-y-2">
          <Label>Vorname</Label>
          <Input {...form.register("vorname")} disabled={readOnly} />
          {form.formState.errors.vorname && (
            <p className="text-xs text-destructive">
              {form.formState.errors.vorname.message}
            </p>
          )}
        </div>

        <div className="space-y-2">
          <Label>Name</Label>
          <Input {...form.register("name")} disabled={readOnly} />
          {form.formState.errors.name && (
            <p className="text-xs text-destructive">
              {form.formState.errors.name.message}
            </p>
          )}
        </div>

        <div className="space-y-2">
          <Label>Strasse</Label>
          <Input {...form.register("strasse")} disabled={readOnly} />
          {form.formState.errors.strasse && (
            <p className="text-xs text-destructive">
              {form.formState.errors.strasse.message}
            </p>
          )}
        </div>

        <div className="space-y-2">
          <Label>PLZ</Label>
          <Input {...form.register("plz")} maxLength={5} disabled={readOnly} />
          {form.formState.errors.plz && (
            <p className="text-xs text-destructive">
              {form.formState.errors.plz.message}
            </p>
          )}
        </div>

        <div className="space-y-2">
          <Label>Ort</Label>
          <Input {...form.register("ort")} disabled={readOnly} />
          {form.formState.errors.ort && (
            <p className="text-xs text-destructive">
              {form.formState.errors.ort.message}
            </p>
          )}
        </div>

        <div className="space-y-2">
          <Label>Email</Label>
          <Input {...form.register("email")} type="email" disabled={readOnly} />
          {form.formState.errors.email && (
            <p className="text-xs text-destructive">
              {form.formState.errors.email.message}
            </p>
          )}
        </div>

        <div className="space-y-2">
          <Label>Telefon</Label>
          <Input {...form.register("telefon")} disabled={readOnly} />
          {form.formState.errors.telefon && (
            <p className="text-xs text-destructive">
              {form.formState.errors.telefon.message}
            </p>
          )}
        </div>
      </div>

      {!readOnly && (
        <div className="flex gap-2 pt-2">
          <Button type="submit" disabled={isPending}>
            {isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
            Save
          </Button>
          <Button
            type="button"
            variant="outline"
            onClick={() => form.reset(defaultValues)}
          >
            Reset
          </Button>
        </div>
      )}
    </form>
  );
}

export function UserForm({ readOnly = false }: { readOnly?: boolean } = {}) {
  const { query, mutation } = useUserConfig();

  if (query.isLoading || !query.data) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>User Data</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <Skeleton key={i} className="h-10 w-full" />
          ))}
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>User Data</CardTitle>
        <CardDescription>
          Personal data used for apartment contact forms
        </CardDescription>
      </CardHeader>
      <CardContent>
        <UserFormInner
          defaultValues={query.data.user_data}
          onSave={(values) => mutation.mutate({ user_data: values })}
          isPending={mutation.isPending}
          readOnly={readOnly}
        />
      </CardContent>
    </Card>
  );
}
